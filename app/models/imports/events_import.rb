class EventsImport < Import
  def kind
    "events"
  end
  
  def process(parsed_row)
    row_valid?(parsed_row)
    person      = create_person(parsed_row)
    event       = create_event(parsed_row, person)
    show        = create_show(parsed_row, event)
    chart       = create_chart(parsed_row, event, show)
    ticket      = create_ticket(parsed_row, person, event, show, chart)
    order       = create_order(parsed_row, person, event, show, ticket)
    actions     = create_actions(parsed_row, person, event, show, order)
  end
  
  def rollback 
    self.people.destroy_all
  end
  
  def row_valid?(parsed_row)
    Rails.logger.debug("EVENT_IMPORT: Validating Row")
    raise Import::RowError, 'No Event Name included in this row' unless parsed_row.event_name 
    raise Import::RowError, 'No Show Date included in this row' unless parsed_row.show_date
    begin
      DateTime.strptime(parsed_row.show_date, DATE_INPUT_FORMAT)
    rescue
      raise Import::RowError, 'Invalid show date' 
    end
    true
  end
  
  def create_chart(parsed_row, event, show)
    Rails.logger.debug("EVENT_IMPORT: Creating chart")
    chart = show.chart || show.create_chart(:name => event.name)    
    Rails.logger.debug("EVENT_IMPORT: Using chart:")
    Rails.logger.debug("EVENT_IMPORT: #{chart.inspect}")
    amount = parsed_row.amount || 0
    Rails.logger.debug("EVENT_IMPORT: Amount is [#{amount}]")
    section = chart.sections.where(:price => amount).first || chart.sections.build(:name => event.name,:price => amount, :capacity => 1)    
    Rails.logger.debug("EVENT_IMPORT: Using section:")
    Rails.logger.debug("EVENT_IMPORT: #{section.inspect}")
    Rails.logger.debug("EVENT_IMPORT: Bumping section capacity")
    section.capacity = section.capacity + 1 unless section.new_record?
    Rails.logger.debug("EVENT_IMPORT: Saving section")
    section.save
    Rails.logger.debug("EVENT_IMPORT: #{section.inspect}")
    Rails.logger.debug("EVENT_IMPORT: Saving chart")
    chart.save
    Rails.logger.debug("EVENT_IMPORT: #{show.inspect}")
    saved = show.save(:validate => false)
    Rails.logger.debug("EVENT_IMPORT: Show saved[#{saved}]")
    chart
  end

  def create_event(parsed_row, person)
    Rails.logger.debug("EVENT_IMPORT: Creating event")
    event = Event.where(:name => parsed_row.event_name).where(:organization_id => self.organization).first
    return event if event
      
    event = Event.new
    event.name = parsed_row.event_name
    event.organization = self.organization
    event.venue = Venue.new
    event.venue.name = parsed_row.venue_name
    event.venue.organization = self.organization
    event.import = self
    event.save!
    Rails.logger.debug("EVENT_IMPORT: Created event #{event.inspect}")
    unless event.charts.empty?
      Rails.logger.debug("EVENT_IMPORT: Default event chart created #{event.charts.first.inspect}") 
    end
    event
  end
  
  def create_show(parsed_row, event)
    Rails.logger.debug("EVENT_IMPORT: Creating show")
    show_key = [parsed_row.show_date, event.name].join("-")
    @imported_shows ||= {}
    show = @imported_shows[show_key]
    return show if show
    
    show = Show.new
    show.datetime = DateTime.strptime(parsed_row.show_date, DATE_INPUT_FORMAT)
    show.event = event
    show.organization = self.organization
    
    #Hacky, but we have to end-around state machine here because we don't have a chart
    show.state = "unpublished"
    show.save(:validate => false)
    
    @imported_shows[show_key] = show
    show
  end
  
  def create_actions(parsed_row, person, event, show, order)
    Rails.logger.debug("EVENT_IMPORT: Creating actions")
    go_action = GoAction.for(show, person)
    go_action.import = self
    go_action.save
     
    #get action is created by the order
    get_action = GetAction.where(:subject_id => order.id).first
    get_action.update_attribute(:occurred_at, DateTime.strptime(parsed_row.order_date, Import::DATE_INPUT_FORMAT)) unless parsed_row.order_date.blank?
    
    return go_action, get_action
  end
  
  def create_ticket(parsed_row, person, event, show, chart)
    Rails.logger.debug("EVENT_IMPORT: Creating ticket")
    amount = parsed_row.amount || 0
    Rails.logger.debug("EVENT_IMPORT: Amount is [#{amount}]")
    section = chart.sections.where(:price => amount).first
    Rails.logger.debug("EVENT_IMPORT: Section is [#{section.inspect}]")
    
    raise Import::RuntimeError, 'No section found for ticket' unless section
    
    ticket = Ticket.build_one(show, section, section.price,1, true)
    Rails.logger.debug("EVENT_IMPORT: Ticket built [#{ticket.inspect}]")
    ticket.sell_to person
    Rails.logger.debug("EVENT_IMPORT: Ticket sold to [#{person.inspect}]")
    ticket.save
    Rails.logger.debug("EVENT_IMPORT: Ticket saved [#{ticket.inspect}]")
    ticket
  end
   
  def create_order(parsed_row, person, event, show, ticket)
    Rails.logger.debug("EVENT_IMPORT: Creating order")
    order_key = [show.id.to_s,person.id.to_s,parsed_row.payment_method].join('-')
    @imported_orders ||= {}
    order = @imported_orders[order_key] || ImportedOrder.new
    order.organization = self.organization
    order.payment_method = parsed_row.payment_method
    order.person = person
    order.details = "Imported by #{user.email} on #{self.created_at_local_to_organization}"
    order.import = self
    item = Item.for(ticket)
    item.state = "settled"
    order.items << item
    order.save
    order.update_attribute(:created_at, DateTime.strptime(parsed_row.order_date, Import::DATE_INPUT_FORMAT)) unless parsed_row.order_date.blank?
    order.actions.where(:type => "GetAction").first.update_attribute(:occurred_at, parsed_row.order_date) unless parsed_row.order_date.blank?
    @imported_orders[order_key] = order
    order
  end
  
  def events_hash
    return @events if @events
    @events = {}
    parsed_rows.each do |row|
      key = (row.event_name || "") + (row.venue_name || "") + (row.show_date.to_s || "")
      @events[key] ||= []
      @events[key] << row
    end
    @events
  end
end
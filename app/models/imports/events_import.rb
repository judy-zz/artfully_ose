class EventsImport < Import
  def kind
    "events"
  end
  
  def process(parsed_row)
    return if !row_valid?(parsed_row)
    person      = create_person(parsed_row)
    event       = create_event(parsed_row, person)
    show        = create_show(parsed_row, event)
    chart       = create_chart(parsed_row, event, show)
    ticket      = create_ticket(parsed_row, person, event, show, chart)
    order       = create_order(parsed_row, person, event, show, ticket)
    actions     = create_actions(parsed_row, person, event, show, order)
  end
  
  def row_valid?(parsed_row)
    !parsed_row.event_name || (parsed_row.event_name && parsed_row.show_date)
  end
  
  def create_chart(parsed_row, event, show)
    chart = show.chart || Chart.new(:name => event.name)
    amount = parsed_row.amount || 0
    section = chart.sections.where(:price => amount).first || chart.sections.build(:name => event.name,:price => amount, :capacity => 1)
    section.capacity = section.capacity + 1 unless section.new_record?
    section.save
    chart.save
    show.chart = chart
    show.save(:validate => false)
    chart
  end

  def create_event(parsed_row, person)
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
    event
  end
  
  def create_show(parsed_row, event)
    show_key = [parsed_row.show_date, event.name].join("-")
    @imported_shows ||= {}
    show = @imported_shows[show_key]
    return show if show
    
    show = Show.new
    show.datetime = DateTime.parse(parsed_row.show_date)
    show.event = event
    show.organization = self.organization
    
    #Hacky, but we have to end-around state machine here because we don't have a chart
    show.state = "unpublished"
    show.save(:validate => false)
    
    @imported_shows[show_key] = show
    show
  end
  
  def create_actions(parsed_row, person, event, show, order)
    go_action = GoAction.for(show, person)
    go_action.import = self
    go_action.save
     
    #get action is created by the order
    get_action = GetAction.where(:subject_id => order.id).first
    
    return go_action, get_action
  end
  
  def create_ticket(parsed_row, person, event, show, chart)
    amount = parsed_row.amount || 0
    section = chart.sections.where(:price => amount).first
    ticket = Ticket.build_one(show, section, section.price,1, true)
    ticket.sell_to person
    ticket.save
    ticket
  end
   
  def create_order(parsed_row, person, event, show, ticket)
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
    order.update_attribute(:created_at, parsed_row.order_date) unless parsed_row.order_date.blank?
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
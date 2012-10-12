class Import < ActiveRecord::Base
  
  include Imports::Status
  include Imports::Processing

  has_many :import_errors, :dependent => :delete_all
  has_many :import_rows, :dependent => :delete_all
  has_many :people, :dependent => :destroy
  has_many :actions, :dependent => :destroy
  has_many :events, :dependent => :destroy
  has_many :orders, :dependent => :destroy

  serialize :import_headers
  
  set_watch_for :created_at, :local_to => :organization

  def self.build(type)
    (type.eql? "events") ? EventsImport.new : PeopleImport.new
  end

  def headers
    self.import_headers
  end

  def rows
    self.import_rows.map(&:content)
  end

  def perform
    if status == "caching"
      self.cache_data
    elsif status == "approved"
      self.import
    end
  end

  def import
    self.importing!

    self.people.destroy_all
    self.import_errors.delete_all

    rows.each do |row|
      parsed_row  = ParsedRow.parse(headers, row)
      person      = create_person(parsed_row)
      
      if parsed_row.importing_event?
        break if !valid_for_event? parsed_row
        event       = create_event(parsed_row, person)
        show        = create_show(parsed_row, event)
        chart       = create_chart(parsed_row, event, show)
        ticket      = create_ticket(parsed_row, person, event, show, chart)
        order       = create_order(parsed_row, person, event, show, ticket)
        actions     = create_actions(parsed_row, person, event, show, order)
      end
    end

    if failed?
      self.people.destroy_all
      #TODO: need to clean up everything.  Maybe should vlaidate first, then import?
    else
      self.imported!
    end
  end
  
  def valid_for_event?(parsed_row)
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
  
  #TODO: include order date  
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
  
  def create_person(parsed_row)
    if parsed_row.importing_event? && !parsed_row.email.blank?
      person = Person.first_or_create(parsed_row.email, self.organization, parsed_row.person_attributes) do |p|
        p.import = self
      end
    else    
      person = attach_person(parsed_row)
      if !person.save
        self.import_errors.create! :row_data => parsed_row.row, :error_message => person.errors.full_messages.join(", ")
        self.reload
        self.failed!
      end 
    end
    person  
  end
  
  def parsed_rows
    return @parsed_rows if @parsed_rows
    @parsed_rows = []
    
    rows.each do |row|
      @parsed_rows << ParsedRow.parse(headers, row)
    end
    @parsed_rows
  end

  def cache_data
    @csv_data = nil

    raise "Cannot load CSV data" unless csv_data.present?

    self.import_headers = nil
    self.import_rows.delete_all
    self.import_errors.delete_all

    csv_data.gsub!(/\\"(?!,)/, '""') # Fix improperly escaped quotes.

    CSV.parse(csv_data, :headers => false) do |row|
      if self.import_headers.nil?
        self.import_headers = row.to_a
        self.save!
      else
        self.import_rows.create!(:content => row.to_a)
      end
    end

    self.pending!
  rescue CSV::MalformedCSVError => e
    error_message = "There was an error while parsing the CSV document: #{e.message}"
    self.import_errors.create!(:error_message => error_message)
    self.failed!
  rescue Exception => e
    self.import_errors.create!(:error_message => e.message)
    self.failed!
  end

  def attach_person(parsed_row)
    ip = parsed_row
    
    person = self.people.build(parsed_row.person_attributes)
    person.organization = self.organization
    person.address = Address.new \
      :address1  => ip.address1,
      :address2  => ip.address2,
      :city      => ip.city,
      :state     => ip.state,
      :zip       => ip.zip,
      :country   => ip.country

    person.tag_list = ip.tags_list.join(", ")

    1.upto(3) do |n|
      kind = ip.send("phone#{n}_type")
      number = ip.send("phone#{n}_number")
      if kind.present? && number.present?
        person.phones << Phone.new(kind: kind, number: number)
      end
    end

    person
  end

end

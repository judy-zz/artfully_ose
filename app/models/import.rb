class Import < ActiveRecord::Base
  
  include Importing::Status
  include Importing::Processing

  has_many :import_errors, :dependent => :delete_all
  has_many :import_rows, :dependent => :delete_all
  has_many :people, :dependent => :destroy

  serialize :import_headers
  
  set_watch_for :created_at, :local_to => :organization

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
      parsed_row  = ImportPerson.new(headers, row)
      person      = create_person(headers, parsed_row)
      
      unless parsed_row.event_name.blank?
        event       = create_event(headers, parsed_row, person)
        show        = create_show(headers, parsed_row, event)
        ticket      = create_ticket(headers, parsed_row, person, event, show)
        order       = create_order(headers, parsed_row, person, event, show, ticket)
        actions     = create_actions(headers, parsed_row, person, event, show, order)
      end
    end

    if failed?
      self.people.destroy_all
    else
      self.imported!
    end
  end

  def create_event(headers, parsed_row, person)
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
  
  def create_show(headers, parsed_row, event)
    @imported_shows = @imported_shows || {}
    show = @imported_shows[parsed_row.show_date]
    return show if show
    
    show = Show.new
    show.datetime = DateTime.parse(parsed_row.show_date)
    show.event = event
    show.organization = self.organization
    
    #Hacky, but we have to end-around state machine here because we don't have a chart
    show.state = "published"
    show.save(:validate => false)
    
    puts show.errors
    
    @imported_shows[parsed_row.show_date] = show
    show
  end
  
  def create_actions(headers, parsed_row, person, event, show, order)
    go_action = GoAction.for(show, person)
    go_action.save
     
    #get action is created by the order
    get_action = GetAction.where(:subject_id => order.id).first
    
    return go_action, get_action
  end
  
  def create_ticket(headers, parsed_row, person, event, show)
    Ticket.build_one(show, nil, 0 ,1, true).tap do |t| 
      t.buyer = person
      t.save
    end
  end
  
  #TODO: Aggregate the order if the person appears multiple times
  #Also include order date  
  def create_order(headers, parsed_row, person, event, show, ticket)
    order = ImportedOrder.new
    order.organization = self.organization
    order.payment_method = parsed_row.payment_method
    order.person = person
    order.details = "Imported by #{user.email} on #{self.created_at_local_to_organization}"
    order.import = self
    item = Item.for(ticket)
    item.state = "settled"
    order.items << item
    order.save
    order
  end
  
  def create_person(headers, parsed_row)
    person = attach_person(parsed_row)
    if !person.save
      self.import_errors.create! :row_data => parsed_row.row, :error_message => person.errors.full_messages.join(", ")
      self.reload
      self.failed!
    end  
    person  
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

  def attach_person(import_person)
    ip = import_person

    person = self.people.build \
      :email           => ip.email,
      :first_name      => ip.first,
      :last_name       => ip.last,
      :company_name    => ip.company,
      :website         => ip.website,
      :twitter_handle  => ip.twitter_username,
      :facebook_url    => ip.facebook_page,
      :linked_in_url   => ip.linkedin_page,
      :organization_id => user.current_organization.id,
      :person_type     => ip.person_type

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

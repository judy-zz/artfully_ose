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

  DATE_INPUT_FORMAT = "%m/%d/%Y"
  
  def self.build(type)
    case type
    when "events"
      EventsImport.new
    when "people"
      PeopleImport.new
    when "donations"
      DonationsImport.new
    else
      nil
    end
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

    begin
      rows.each do |row|
        process(ParsedRow.parse(headers, row))
      end
      self.imported!
    rescue
      fail!
    end
  end
  
  def fail!
    #TODO: Need to clena up other stuff too
    self.people.destroy_all
    failed!
  end
  
  #Subclasses must implement process
  def process(parsed_row)
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

  class RowError < ArgumentError
  end

end

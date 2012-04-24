class Person < ActiveRecord::Base
  acts_as_taggable

  belongs_to  :organization
  has_many    :actions
  has_many    :phones
  has_many    :notes
  has_one     :address
  
  #
  # An array of has_many associations that should be merged with a person record is merge with another
  # When an has_many association is added, it must be added here if the association is to be merged
  #
  def mergables
    [:actions, :notes]
  end

  validates_presence_of :organization_id
  validates_presence_of :person_info

  validates :email, :uniqueness => {:scope => :organization_id}, :allow_blank => true
  after_commit { Sunspot.commit }

  searchable do
    text :first_name, :last_name, :email
    text :address do
      address.to_s unless address.nil?
    end
    
    string :first_name, :last_name, :email
    string :organization_id do
      organization.id
    end
  end

  comma do
    first_name
    last_name
    email
    company_name
    website
    twitter_handle
    facebook_url
    linked_in_url
    phones("Phone1 type") { |phones| phones[0] && phones[0].kind }
    phones("Phone1 number") { |phones| phones[0] && phones[0].number }
    phones("Phone2 type") { |phones| phones[1] && phones[1].kind }
    phones("Phone2 number") { |phones| phones[1] && phones[1].number }
    phones("Phone3 type") { |phones| phones[2] && phones[2].kind }
    phones("Phone3 number") { |phones| phones[2] && phones[2].number }
    tags { |tags| tags.join("|") }
    address("Address 1") { |address| address && address.address1 }
    address("Address 2") { |address| address && address.address2 }
    address("City") { |address| address && address.city }
    address("State") { |address| address && address.state }
    address("Zip") { |address| address && address.zip }
    address("Country") { |address| address && address.country }
  end

  def self.find_by_import(import)
    where('import_id = ?', import.id)
  end

  def self.recent(organization, limit = 10)
    Person.where(:organization_id => organization).order('updated_at DESC').limit(limit)
  end
  
  def self.find_by_email_and_organization(email, organization)
    return nil if email.nil? 
    find(:first, :conditions => { :email => email, :organization_id => organization.id })
  end

  def self.find_by_organization(organization)
    find_by_organization_id(organization.id)
  end

  def self.dummy_for(organization)
    dummy = find(:first, :conditions => { :organization_id => organization.id, :dummy => true })
    if dummy.nil?
      create_dummy_for(organization)
    else
      dummy
    end
  end

  def self.create_dummy_for(organization)
    create({
      :first_name      => "Anonymous",
      :email           => "anonymous@artfullyhq.com",
      :dummy           => true,
      :organization_id => organization.id
    })
  end

  def to_customer
    AthenaCustomer.new(:person_id => id, :email => email, :first_name => first_name, :last_name => last_name)
  end

  def starred_actions
    actions.select { |action| action.starred? }
  end

  def unstarred_actions
    actions.select { |action| action.unstarred? }
  end

  def self.search_index(query, organization)
    self.search do
      keywords query
      with(:organization_id).equal_to(organization.id)
    end.results
  end

  #
  # You can pass any object as first param as long as it responds to
  # .first_name, .last_name, and .email
  #
  def self.find_or_create(customer, organization)
    person = Person.find_by_email_and_organization(customer.email, organization)
      
    if person.nil?
      params = {
        :first_name      => customer.first_name,
        :last_name       => customer.last_name,
        :email           => customer.email,
        :organization_id => organization.id # This doesn't account for multiple organizations per cart
      }
      person = Person.create(params)
    end
    person
  end

  def update_address(new_address, time_zone, user = nil, updated_by = nil)
    unless new_address.nil?
      # If new_address is a hash, then upgrade it to an Address:
      if !new_address.respond_to?(:person=) then new_address = Address.create(new_address) end
      new_address.person = self
      @address = Address.find_or_create(id)
      if !@address.update_with_note(self, user, new_address, time_zone, updated_by)
        ::Rails.logger.error "Could not update address from payment"
        return false
      end
    end
    true
  end

  private
    def person_info
      !(first_name.blank? and last_name.blank? and email.blank?)
    end
end

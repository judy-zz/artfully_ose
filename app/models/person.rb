class Person < ActiveRecord::Base
  acts_as_taggable

  belongs_to :organization
  has_many :actions
  has_one :address
  has_many :phones

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
    phones("Phone2 type") { |phones| phones[0] && phones[0].kind }
    phones("Phone2 number") { |phones| phones[0] && phones[0].number }
    phones("Phone3 type") { |phones| phones[0] && phones[0].kind }
    phones("Phone3 number") { |phones| phones[0] && phones[0].number }
    tags { |tags| tags.join(" ") }
    address("Address 1") { |address| address.address1 }
    address("Address 2") { |address| address.address2 }
    address("City") { |address| address.city }
    address("State") { |address| address.state }
    address("Zip") { |address| address.zip }
    address("Country") { |address| address.country }
  end

  def self.find_by_import(import)
    where('import_id = ?', import.id)
  end

  #TODO
  def self.recent(organization)
    []
  end

  def self.find_by_email_and_organization(email, organization)
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
    AthenaCustomer.new(:email => email, :first_name => first_name, :last_name => last_name)
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

  private
    def person_info
      !(first_name.blank? and last_name.blank? and email.blank?)
    end
end

require 'comma'
class AthenaPerson < AthenaResource::Base
  self.site = Artfully::Application.config.people_site
  self.element_name = 'people'
  self.collection_name = 'people'

  validates_presence_of :organization_id
  validates_presence_of :person_info
  validate :uniqueness, :unless => lambda { |person| person.email.blank? }

  schema do
    attribute 'id',             :integer
    attribute 'email',          :string
    attribute 'first_name',     :string
    attribute 'last_name',      :string
    attribute 'company_name',   :string
    attribute 'website',        :string
    attribute 'organization_id',:integer
    attribute 'tags',           :string
    attribute 'phones',         :string
    attribute 'dummy',          :string
    attribute 'import_id',      :integer
    attribute 'twitter_handle', :string
    attribute 'facebook_url',   :string
    attribute 'linked_in_url',  :string
    attribute 'person_type',    :string
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
    phones("Phone1 type") { |phones| phones[0] && phones[0].type }
    phones("Phone1 number") { |phones| phones[0] && phones[0].number }
    phones("Phone2 type") { |phones| phones[0] && phones[0].type }
    phones("Phone2 number") { |phones| phones[0] && phones[0].number }
    phones("Phone3 type") { |phones| phones[0] && phones[0].type }
    phones("Phone3 number") { |phones| phones[0] && phones[0].number }
    tags { |tags| tags.join(" ") }
  end

  #TODO: This isn't actually recent, but that's an Athena problem, not an artfully problem
  def self.recent(organization)
    search_index(nil, organization)
  end

  def initialize(attributes = {})
    super(attributes)
    load_tags
    load_phones
  end

  #ATHENA doesn't let you patch arrays, otherwise it would be smart to do the patch
  #right here in this method
  def tag!(tag_text)
    tags << tag_text
  end

  def untag!(tag_text)
    tags.delete tag_text
  end

  def self.find_by_email_and_organization(email, organization)
    find(:first, :params => { :email => "eq#{email}", :organizationId => "eq#{organization.id}"})
  end

  def self.find_by_organization(organization)
    find_by_organization_id(organization.id)
  end

  def self.find_by_import(import)
    find(:all, :params => { :importId => "eq#{import.id}" })
  end

  def organization
    @organization ||= Organization.find(organization_id)
  end

  def organization=(org)
    raise TypeError, "Expecting an Organization" unless org.kind_of? Organization
    org.save unless org.persisted?
    @organization, self.organization_id = org, org.id
  end

  def dummy?
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(dummy)
  end

  def self.dummy_for(organization)
    dummy = find(:first, :params => { :organizationId => "eq#{organization.id}", :dummy => true })
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

  #Sort of a verbose Java-like pattern, but it makes the views very readable
  def actions
    @actions ||= AthenaAction.find_by_person_and_organization(self, organization)
  end

  def starred_actions
    actions.select { |action| action.starred? }
  end

  def unstarred_actions
    actions.select { |action| action.unstarred? }
  end

  def relationships
    @relationships ||= AthenaRelationship.find_by_person(self)
  end

  def starred_relationships
    relationships.select { |relationship| relationship.starred? }
  end

  def unstarred_relationships
    relationships.select { |relationship| relationship.unstarred? }
  end

  def address
    find_address || Address.new
  end

  def phones
    attributes['phones']
  end

  private
  def load_tags
    self.tags = Array.wrap(self.tags) unless self.tags.kind_of? Array
  end

  def load_phones
    self.phones = Array.wrap(self.phones).collect{ |serialized_phone| AthenaPerson::Phone.deserialize(serialized_phone) }
  end

  def person_info
    !(first_name.blank? and last_name.blank? and email.blank?)
  end

  def find_address
    Address.find_by_person_id(self.id).first || Address.new
  end

  def uniqueness
    errors.add(:base, "Another person record already exists with this email address.") unless unique?
  end

  def unique?
    doppleganger = self.class.find_by_email_and_organization(self.email, self.organization)
    doppleganger.nil? or (persisted? and doppleganger.id == self.id)
  end
end

class AthenaPerson::Phone
  attr_accessor :type, :number

  def initialize(type, number)
    @type = type
    @number = number
    clean_phone
  end

  def self.types
    [ "Work", "Home", "Cell", "Fax" ]
  end

  def id
    attributes.values.join("+")
  end

  def number=(number)
    @number = number
    clean_phone
  end

  def formatted_number
    formattable? ? number.dup.insert(3,"-").insert(-5, "-") : number
  end

  def attributes
    {
      :type => type,
      :number => number
    }
  end

  def self.deserialize(serialized)
    type, number = serialized.split(':')
    new(type, number)
  end

  def encode(options = {})
    attributes.values.join(":")
  end

  private

  def formattable?
    number.present? and (number.length == 10)
  end

  def clean_phone
    @number = number.gsub(/\D/,"") unless number.blank?
  end
end

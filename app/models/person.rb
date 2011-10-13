#TODO: tags, phones

class Person < ActiveRecord::Base
  acts_as_taggable

  belongs_to :organization
  has_many :actions
  has_one :addresses

  validates_presence_of :email
  validates_presence_of :organization_id
  validates_presence_of :person_info

  validates :email, :uniqueness => true

  comma do
    first_name
    last_name
    email
    company_name
    website
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

  private
    def person_info
      first_name or last_name
    end
end
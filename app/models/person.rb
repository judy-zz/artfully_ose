class Person < ActiveRecord::Base
  acts_as_taggable

  belongs_to :organization
  has_many :actions
  has_one :address
  has_many :phones

  validates_presence_of :organization_id
  validates_presence_of :person_info

  validates :email, :uniqueness => true
  after_commit { Sunspot.commit }

  searchable do
    text :first_name, :last_name, :email
  end

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
      !(first_name.blank? and last_name.blank? and email.blank?)
    end
end
class Person < ActiveRecord::Base
  include Valuation::LifetimeValue
  include Valuation::LifetimeDonations
  
  acts_as_taggable

  belongs_to  :organization
  has_many    :actions
  has_many    :phones
  has_many    :notes
  has_many    :orders
  has_many    :tickets, :foreign_key => 'buyer_id'
  has_one     :address
  
  default_scope where(:deleted_at => nil)

  def destroy!
    destroy
  end

  def destroy
    update_attribute(:deleted_at, Time.now)
  end
  
  def dupe_code
    "#{first_name} | #{last_name} | #{email}"
  end
  
  def self.find_dupes_in(organization)
    hash = {}
    Person.where(:organization_id => organization.id)
          .where(:import_id => nil)
          .includes([:tickets, :actions, :notes, :orders]).each do |p|
      if hash[p.dupe_code].nil?
        hash[p.dupe_code] = Array.wrap(p)
      else
        hash[p.dupe_code] << p
      end
    end
    hash
  end

  #
  # One off method.  Remove this when Libra's records are cleared up
  #
  def self.delete_dupes_in(organization)
    Person.find_dupes_in(organization).each do |k,v|
      if v.length > 100
        puts "Deleting [#{v.length}] of: #{v.first.id} #{v.first.first_name} #{v.first.last_name}"
        v.reject! {|p| p.has_something?}
        Person.delete v
      end
    end
    
    nil
  end
  
  #
  # An array of has_many associations that should be merged when a person record is merged with another
  # When an has_many association is added, it must be added here if the association is to be merged
  #
  # Tickets are a special case
  #
  def self.mergables
    [:actions, :phones, :notes, :orders]
  end
  
  def has_something?
    !has_nothing?
  end
  
  def has_nothing?
    actions.empty? && phones.empty? && notes.empty? && orders.empty? && tickets.empty? && address.nil? && import_id.nil?
  end

  validates_presence_of :organization_id
  validates_presence_of :person_info

  validates :email, :uniqueness => { :scope => [:organization_id, :deleted_at] }, :allow_blank => true
  after_commit { Sunspot.commit }

  searchable do
    text :first_name, :last_name, :email
    text :address do
      address.to_s unless address.nil?
    end
    
    text :tags do
      taggings.map{ |tagging| tagging.tag.name }
    end
    
    text :notes do
      notes.map{ |note| note.text }
    end
    
    string :first_name, :last_name, :email
    string :organization_id do
      organization.id
    end
  end

  def self.search_index(query, organization)
    self.search do
      fulltext query
      with(:organization_id).equal_to(organization.id)
    end.results
  end

  comma do
    email
    first_name
    last_name
    company_name
    address("Address 1") { |address| address && address.address1 }
    address("Address 2") { |address| address && address.address2 }
    address("City") { |address| address && address.city }
    address("State") { |address| address && address.state }
    address("Zip") { |address| address && address.zip }
    address("Country") { |address| address && address.country }
    phones("Phone1 type") { |phones| phones[0] && phones[0].kind }
    phones("Phone1 number") { |phones| phones[0] && phones[0].number }
    phones("Phone2 type") { |phones| phones[1] && phones[1].kind }
    phones("Phone2 number") { |phones| phones[1] && phones[1].number }
    phones("Phone3 type") { |phones| phones[2] && phones[2].kind }
    phones("Phone3 number") { |phones| phones[2] && phones[2].number }
    website
    twitter_handle
    facebook_url
    linked_in_url
    tags { |tags| tags.join("|") }
    person_type
  end

  def self.find_by_import(import)
    where('import_id = ?', import.id)
  end

  def self.recent(organization, limit = 10)
    Person.where(:organization_id => organization).order('updated_at DESC').limit(limit)
  end
  
  def self.merge(winner, loser)
    unless winner.organization == loser.organization
      raise "Trying to merge two people [#{winner.id}] [#{loser.id}] from different organizations [#{winner.organization.id}] [#{winner.organization.id}]"
    end
    
    mergables.each do |mergable|
      loser.send(mergable).each do |m|
        m.update_attribute(:person, winner)
      end
    end
    
    loser.tickets.each do |ticket|
      ticket.update_attribute(:buyer, winner)
    end
    
    loser.tags.each do |t|
      winner.tag_list << t.name unless winner.tag_list.include? t.name
    end

    winner.lifetime_value += loser.lifetime_value
    winner.lifetime_donations += loser.lifetime_donations
    
    winner.save!
    loser.destroy!
    return winner
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
    Action.where({ :person_id => id, :starred => true }).order(:occurred_at)
  end

  def unstarred_actions
    Action.where({ :person_id => id }).order('occurred_at desc').select{|a| a.unstarred?}
  end

  #
  # You can pass any object as first param as long as it responds to
  # .first_name, .last_name, and .email
  #
  def self.find_or_create(customer, organization)
    if (customer.respond_to? :person_id) && (!customer.person_id.nil?)
      return Person.find(customer.person_id)
    end
    
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

  # Needs a serious refactor
  def update_address(new_address, time_zone, user = nil, updated_by = nil)
    unless new_address.nil?
      new_address = Address.unhash(new_address) 
      new_address.person = self
      @address = Address.find_or_create(id)
      if !@address.update_with_note(self, user, new_address, time_zone, updated_by)
        ::Rails.logger.error "Could not update address from payment"
        return false
      end
      self.address = @address
      save
    end
    true
  end

  # The name of this method makes no sense
  def add_phone_if_missing(new_phone)
    if (!new_phone.blank? and phones.where("number = ?", new_phone).empty?)
      phones.create(:number => new_phone, :kind => "Other")
    end
  end

  private
    def person_info
      !(first_name.blank? and last_name.blank? and email.blank?)
    end
end

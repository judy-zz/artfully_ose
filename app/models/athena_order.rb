# Used for artful.ly orders (and not for checkout in the api/widget)
class AthenaOrder < AthenaResource::Base
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
  
  self.site = Artfully::Application.config.orders_component
  self.element_name = 'orders'
  self.collection_name = 'orders'

  attr_accessor :skip_actions

  schema do
    attribute :person_id,       :integer
    attribute :organization_id, :integer
    attribute :customer_id,     :string
    attribute :transaction_id,  :string
    attribute :parent_id,       :string
    attribute :price,           :integer
    attribute :details,         :string
    attribute :timestamp,       :string
    
    #pseudo people
    attribute :first_name,      :string
    attribute :last_name,       :string
    attribute :email,           :string
    
    #fa attributes
    attribute :check_no,    :string
    attribute :fa_id,       :string
  end

  validates_presence_of :person_id, :unless => lambda { person_information_present? }
  validates_presence_of :organization_id

  before_save :set_timestamp
  after_save :save_items, :unless => lambda { items.empty? }
  after_save :create_purchase_action, :unless => :skip_actions
  after_save :create_donation_actions, :unless => :skip_actions

  def person
    @person ||= find_person
  end

  def person_information_present?
    !(first_name.nil? || last_name.nil? || email.nil?)
  end

  def person=(person)
    if person.nil?
      @person = person_id = person
      return
    end

    raise TypeError, "Expecting an Person" unless person.kind_of? Person
    @person, self.person_id = person, person.id
  end

  def organization
    @organization ||= Organization.find(organization_id)
  end

  def organization=(org)
    raise TypeError, "Expecting an Organization" unless org.kind_of? Organization
    org.save unless org.persisted?
    @organization, self.organization_id = org, org.id
  end

  def parent
    @parent ||= find_parent
  end

  def parent=(parent)
    if parent.nil?
      @parent = parent_id = nil
      return
    end

    @parent, self.parent_id = parent, parent.id
  end

  def children
    @children ||= AthenaOrder.find(:all, :params => { :parentId => self.id } )
  end

  def customer
    @customer ||= find_customer
  end

  def customer=(customer)
    if customer.nil?
      @customer = customer_id = nil
      return
    end

    raise TypeError, "Expecting an AthenaCustomer" unless customer.kind_of? AthenaCustomer
    @customer, self.customer_id = customer, customer.id
  end

  def total
    all_items.inject(0) {|sum, item| sum + item.price.to_i }
  end

  def nongift_amount
    all_items.inject(0) {|sum, item| sum + item.nongift_amount.to_i }
  end

  def items
    @items ||= find_items
  end

  def items=(items)
    @items = items
  end

  def tickets
    items.select(&:ticket?)
  end

  def donations
    items.select(&:donation?)
  end

  def for_organization(org)
    self.organization = org
  end

  def <<(products)
    self.items += Array.wrap(products).collect { |product| AthenaItem.for(product) }
  end

  def payment
    AthenaPayment.new(:transaction_id => transaction_id)
  end

  def record_exchange!
    items.each do |item|
      item.to_exchange!
    end
  end

  def self.in_range(start, stop, org_id=nil)
    start = "gt#{start.xmlschema}"
    stop = "lt#{stop.xmlschema}"

    org_query = "organizationId=eq#{org_id}&" unless org_id.nil?

    instantiate_collection(query("#{org_query}timestamp=#{start}&timestamp=#{stop}"))
  end

  def all_items
    @all_items ||= merge_and_sort_items
  end

  def all_tickets
    all_items.select(&:ticket?)
  end

  def all_donations
    all_items.select(&:donation?)
  end

  def settleable_donations
    all_donations.reject(&:modified?)
  end

  def refundable_items
    items.select(&:refundable?)
  end

  def exchangeable_items
    items.select(&:exchangeable?)
  end

  def items_detail
    num_tickets = 0
    sum_donations = 0

    all_items.each{ |item|
      if item.ticket?
        num_tickets += 1
      elsif item.donation?
        sum_donations += item.price.to_i
      end }

    tickets = "#{num_tickets} ticket(s)"
    donations = "$#{sum_donations/100.00} donation"

    if num_tickets == 0
      result = "#{[donations].to_sentence}"
    elsif sum_donations == 0.0
      result = "#{[tickets].to_sentence}"
    else
      result = "#{[tickets, donations].to_sentence}"
    end

    result.to_sentence
  end

  def num_tickets
    all_tickets.size
  end

  def has_ticket?
    items.select(&:ticket?).present?
  end

  def has_donation?
    items.select(&:donation?).present?
  end

  def sum_donations
    all_donations.collect{|item| item.price.to_i}.sum
  end

  def ticket_details
    "#{num_tickets} ticket(s)"
  end
  
  def is_fafs?
    !fa_id.nil?
  end

  def donation_details
    if is_fafs?
      o = Organization.find(organization_id)
      "#{number_as_cents sum_donations} donation via Fractured Atlas for the benefit of #{o.fiscally_sponsored_project.name}"
    else
      "#{number_as_cents sum_donations} donation"
    end
  end

  def returnable_items
    items.select { |i| i.returnable? and not i.refundable? }
  end

  def timestamp
    attributes['timestamp'] = attributes['timestamp'].in_time_zone(Organization.find(organization_id).time_zone)
    return attributes['timestamp']
  end
  
  def self.find_by_fa_id(fa_id)
    o = find(:all, :params => { :faId => fa_id }).first
    return if o.nil?
    o.skip_actions = true
    o
  end
  
  def self.from_fa_donation(fa_donation, organization)
    @order = AthenaOrder.find_by_fa_id(fa_donation.id) || AthenaOrder.new

    @order.organization_id  = organization.id
    @order.timestamp        = DateTime.parse fa_donation.date
    @order.price            = (fa_donation.amount.to_f * 100).to_i
    @order.first_name       = fa_donation.donor.first_name || ""
    @order.last_name        = fa_donation.donor.last_name || ""
    @order.fa_id            = fa_donation.id
    
    #This should go to the anonymous record
    @order.email            = fa_donation.donor.email || ""
    
    if @order.items.blank?
      @order.items << AthenaItem.from_fa_donation(fa_donation, organization, @order)
    else
      item = @order.items.first.copy_fa_donation(fa_donation)
    end
    
    @order.save
    @order
  end  

  private
  
    def merge_and_sort_items
      items.concat(children.collect(&:items).flatten)
    end

    def create_purchase_action
      unless all_tickets.empty?
        action                 = AthenaPurchaseAction.new
        action.person          = person
        action.subject         = self
        action.organization_id = organization.id
        action.timestamp       = self.timestamp
        action.details         = ticket_details
        action.occurred_at     = action.timestamp
        action.action_subtype  = "Purchase"

        logger.debug("Creating action: #{action}, with org id #{action.organization_id}")
        logger.debug("Action: #{action.attributes}")
        action.save!
        action
      end
    end

    def create_donation_actions
      items.select(&:donation?).collect do |item|
        action                 = DonationAction.new
        action.person          = person
        action.subject         = item.product
        action.organization_id = organization.id
        action.timestamp       = self.timestamp
        action.details         = donation_details
        action.occurred_at     = action.timestamp
        action.action_subtype  = "Donation"
        action.save!
        action
      end
    end

    def save_items
      items.each do |item|
        item.order = self
        item.save
      end
    end

    def find_person
      return if self.person_id.nil?

      begin
        Person.find(self.person_id)
      rescue ActiveResource::ResourceNotFound
        return nil
      end
    end

    def find_parent
      return if self.parent_id.nil?

      begin
        AthenaOrder.find(parent_id)
      rescue ActiveResource::ResourceNotFound
        return nil
      end
    end

    def find_customer
      return if self.customer_id.nil?

      begin
        AthenaCustomer.find(self.customer_id)
      rescue ActiveResource::ResourceNotFound
        return nil
      end
    end

    def find_items
      return [] if new_record?
      AthenaItem.find_by_order(self)
    end

    def set_timestamp
      if @attributes['timestamp'].nil?
        @attributes['timestamp'] = DateTime.now
      end
    end

end
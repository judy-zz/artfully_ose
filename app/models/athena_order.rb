# Used for artful.ly orders (and not for checkout in the api/widget)
class AthenaOrder < AthenaResource::Base
  self.site = Artfully::Application.config.orders_component
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'orders'
  self.collection_name = 'orders'

  schema do
    attribute :person_id,       :integer
    attribute :organization_id, :integer
    attribute :customer_id,     :string
    attribute :transaction_id,  :string
    attribute :parent_id,       :string
    attribute :price,           :integer
    attribute :details,         :string
    attribute :timestamp,       :string
  end

  validates_presence_of :person_id
  validates_presence_of :organization_id

  before_save :set_timestamp
  after_save :save_items, :unless => lambda { items.empty? }
  after_save :create_purchase_action
  after_save :create_donation_actions

  def person
    @person ||= find_person
  end

  def person=(person)
    if person.nil?
      @person = person_id = person
      return
    end

    raise TypeError, "Expecting an AthenaPerson" unless person.kind_of? AthenaPerson
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

  def items
    @items ||= find_items
  end

  def items=(items)
    @items = items
  end

  def for_organization(org)
    self.organization = org
  end

  def <<(itms)
    self.items += Array.wrap(itms).collect { |item| AthenaItem.for(item) }
  end

  def payment
    AthenaPayment.new(:transaction_id => transaction_id)
  end

  def all_items
    @all_items ||= merge_and_sort_items
  end

  def all_tickets
    all_items.select{|item| item.item_type == "AthenaTicket" }
  end

  def all_donations
    all_items.select{|item| item.item_type == "Donation" }
  end

  def refundable_items
    items.select(&:refundable?)
  end

  def exchangeable_items
    items.select(&:exchangeable?)
  end

  def items_detail
    result = []

    if sum_donations > 0.0
      result << donation_details
    end    
    if num_tickets > 0
      result << ticket_details
    end

    result.to_sentence
  end
  
  def num_tickets
    all_tickets.size
  end

  def sum_donations
    all_donations.collect{|item| item.price.to_i}.sum
  end

  def ticket_details
    "#{num_tickets} ticket(s)"
  end

  def donation_details
    "$#{sum_donations/100.00} donation"
  end

  def returnable_items
    items.select { |i| i.returnable? and not i.refundable? }
  end

  def timestamp
    attributes['timestamp'] = attributes['timestamp'].in_time_zone(Organization.find(organization_id).time_zone)
    return attributes['timestamp']
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
      items.select { |item| item.item_type == "Donation" }.collect do |item|
        action                 = AthenaDonationAction.new
        action.person          = person
        action.subject         = Donation.find(item.item_id)
        action.organization_id = organization.id
        action.timestamp       = self.timestamp
        action.details         = ticket_details
        action.occurred_at     = action.timestamp
        action.action_subtype  = "Donation"
  
        logger.debug("Creating action: #{action}, with org id #{action.organization_id}")
        logger.debug("Action: #{action.attributes}")
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
        AthenaPerson.find(self.person_id)
      rescue ActiveResource::ResourceNotFound
        update_attribute!(:person_id, nil)
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
        update_attribute!(:customer_id, nil)
        return nil
      end
    end

    def find_items
      return [] if new_record?
      items ||= AthenaItem.find_by_order(self)
    end

    def set_timestamp
      if @attributes['timestamp'].nil?
        @attributes['timestamp'] = DateTime.now
      end
    end

end
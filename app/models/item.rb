class Item < ActiveRecord::Base

  belongs_to :order
  belongs_to :show
  belongs_to :settlement
  belongs_to :reseller_order, :class_name => "Reseller::Order"
  belongs_to :product, :polymorphic => true

  attr_accessible :order_id, :product_type, :state, :price, :realized_price, :net
  
  #This is a lambda used to by the items to calculate their net
  attr_accessor :per_item_processing_charge

  validates_presence_of :product_type, :price, :realized_price, :net
  validates_inclusion_of :product_type, :in => %( Ticket Donation )

  scope :donation, where(:product_type => "Donation")

  scope :imported, joins(:order).merge(Order.imported)
  scope :not_imported, joins(:order).merge(Order.not_imported)

  comma :donation do
    order("First Name") { |order| order.person.first_name if order.person }
    order("Last Name") { |order| order.person.last_name if order.person }
    order("Company Name") { |order| order.person.company_name if order.person }
    order("Donation Date") { |order| order.created_at }
    total_price("Amount") { |cents| number_to_currency(cents.to_f/100) if cents }
    nongift_amount("Non-deductible") { |cents| number_to_currency(cents.to_f/100) if cents }
  end

  comma :ticket_sale do
    order("Date of Purchase") { |order| order.created_at }
    order("First Name") { |order| order.person.first_name if order.person }
    order("Last Name") { |order| order.person.last_name if order.person }
    show("Performance Title") { |show| show.event.name if show }
    show("Performance Date-Time") { |show| show.datetime_local_to_event if show }
    price("Ticket Price") { |cents| number_to_currency(cents.to_f/100) if cents }
    order("Special Instructions") { |order| order.special_instructions }
  end

  def ticket?
    product_type == "Ticket"
  end

  def donation?
    product_type == "Donation"
  end

  #
  # Donations stored in the FA DB are stored like so:
  # $100 sent
  # amount = $50
  # nongift = $50
  #
  # So, unfortunately, they arrive at artfully in the same manner.
  # That means, for donations, an item's "price" is actually the gift amount of the donation
  # and the "total_price" is the amount that was transacted (amount + nongift)
  #
  def total_price
    price + (nongift_amount.nil? ? 0 : nongift_amount.to_i)  
  end

  def self.for(prod, per_item_lambda=lambda { |item| 0 })
    Item.new.tap do |i|
      i.per_item_processing_charge = per_item_lambda
      i.product = prod 
    end
  end

  def self.find_by_product(product)
    where(:product_type => product.class.to_s).where(:product_id => product.id)
  end

  def product=(product)
    set_product_details_from product
    set_prices_from product
    set_show_from product if product.respond_to? :show_id
    self.state = "purchased"
    self.product_id = if product then product.id end
    self.product_type = if product then product.class.name end
  end

  def dup!
    new_item = self.dup
    new_item.state = nil
    new_item
  end

  def refundable?
    (not modified?) and product.refundable?
  end

  def exchangeable?
    (not modified?) and product.exchangeable?
  end

  def returnable?
    (not modified?) and product.returnable?
  end

  #
  # This looks bad, but here's what's going on
  # the item that gets refunded is state="refunded"
  # then we create a new item to signify the negative amount, state="refund"
  # Should all be pulled out into state machine
  #
  def refund!
    self.state = "refunded"
    self.save
  end

  def to_refund
    dup!.tap do |item|
      item.price = item.price.to_i * -1
      item.realized_price = item.realized_price.to_i * -1
      item.net = item.net.to_i * -1
      item.state = "refund"
    end
  end

  def to_exchange!
    self.price = 0
    self.realized_price = 0
    self.net = 0
    self.state = "exchangee"
  end

  def to_comp!
    self.price = 0
    self.realized_price = 0
    self.net = 0
    self.state = "comped"
  end

  def return!(return_items_to_inventory = true)
    update_attribute(:state, "returned")
    product.return!(return_items_to_inventory) if product.returnable?
  end

  def modified?
    not %w( purchased comped ).include?(state)
  end

  def settled?
    state.eql? "settled"
  end
  
  def purchased?
    state.eql? "purchased"
  end
  
  def comped?
    state.eql? "comped"
  end
  
  def exchangee?
    state.eql? "exchangee"
  end

  def self.find_by_order(order)
    return [] unless order.id?

    self.find_by_order_id(order.id).tap do |items|
      items.each { |item| item.order = order }
    end
  end

  def self.settle(items, settlement)
    if items.blank?
      logger.debug("Item.settle: No items to settle, returning")
      return
    end

    logger.debug("Settling items #{items.collect(&:id).join(',')}")
    self.update_all({:settlement_id => settlement.id, :state => :settled }, { :id => items.collect(&:id)})
  end

  private

    def set_product_details_from(prod)
      self.product_id = prod.id
      self.product_type = prod.class.to_s
    end

    def set_prices_from(prod)
      self.price          = prod.price
      self.realized_price = prod.price - prod.class.fee
      self.net            = (self.realized_price - (per_item_processing_charge || lambda { |item| 0 }).call(self)).floor
    end

    def set_show_from(prod)
      self.show_id = prod.show_id
    end

end

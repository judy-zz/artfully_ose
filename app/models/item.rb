class Item < ActiveRecord::Base
  belongs_to :order
  belongs_to :show

  validates_presence_of :product_type, :price, :realized_price, :net
  validates_inclusion_of :product_type, :in => %( Ticket Donation )

  scope :donation, where(:product_type => "Donation")

  scope :imported, joins(:order).merge(Order.imported)
  scope :not_imported, joins(:order).merge(Order.not_imported)

  comma :donation do
    order("First Name") { |order| order.first_name.present? ? order.first_name : order.person.first_name }
    order("Last Name") { |order| order.last_name.present? ? order.last_name : order.person.last_name }
    order("Company Name") { |order| order.person.company_name }
    order("Donation Date") { |order| order.timestamp }
    price("Gift Amount")
    nongift_amount("Non-gift Amount")
  end

  comma :ticket_sale do
    order("Date of Purchase") { |order| order.timestamp }
    order("First Name") { |order| order.first_name.present? ? order.first_name : order.person.first_name }
    order("Last Name") { |order| order.last_name.present? ? order.last_name : order.person.last_name }
    performance("Performance Title") { |performance| performance.event.name }
    performance("Performance Date-Time") { |performance| performance.datetime }
    price("Ticket Price")
  end
  
  def ticket?
    product_type == "Ticket"
  end

  def donation?
    product_type == "Donation"
  end

  def self.for(prod)
    new.tap { |this| this.product = prod }
  end

  def self.find_by_product(product)
    find(:all, :params => { :productType => product.class.to_s, :productId => product.id })
  end

  def product
    @product ||= find_product
  end

  def product=(product)
    set_product_details_from product
    set_prices_from product
    set_show_from product if product.respond_to? :show_id
    self.state = "purchased"
    @product = product
  end

  def dup!
    self.class.new(attributes.reject { |key, value| %w( id state ).include? key } )
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

  def refund!
    update_attribute(:state, "refunded")
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

  def return!
    update_attribute(:state, "returned")
    product.return! if product.returnable?
  end

  def modified?
    not %w( purchased comped ).include?(state)
  end

  def settled?
    state.eql? "settled"
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
      self.net            = (self.realized_price - (self.realized_price * 0.035)).floor
    end

    def set_show_from(prod)
      self.show_id = prod.show_id
    end

    def find_product
      return if self.product_id.nil?

      begin
        klass = Kernel.const_get(product_type)
        klass.find(product_id)
      rescue NameError
        return nil
      rescue ActiveResource::ResourceNotFound
        return nil
      end
    end
end
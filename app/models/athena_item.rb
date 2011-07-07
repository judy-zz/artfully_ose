class AthenaItem < AthenaResource::Base
  self.site = Artfully::Application.config.orders_component
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'items'
  self.collection_name = 'items'

  schema do
    attribute 'order_id',       :integer
    attribute 'product_type',   :string
    attribute 'product_id',     :string
    attribute 'performance_id', :string
    attribute 'settlement_id',  :string

    attribute 'state',          :string

    attribute 'price',          :integer
    attribute 'realized_price', :integer
    attribute 'net',            :integer
  end

  validates_presence_of :order_id, :product_type, :product_id, :price, :realized_price, :net
  validates_inclusion_of :product_type, :in => %( AthenaTicket Donation )
  validate :product_type_exists

  def product_type_exists
    begin
      Kernel.const_get(product_type)
    rescue NameError
      errors.add(:product_type, "is not a valid type") unless valid_type
    end
  end

  def order
    @order ||= find_order
  end

  def order=(order)
    if order.nil?
      @order = order_id = order
      return
    end

    raise TypeError, "Expecting an AthenaOrder" unless order.kind_of? AthenaOrder
    @order, self.order_id = order, order.id
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
    set_performance_from product if product.respond_to? :performance_id
    self.state = "purchased"
    puts self.state
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
    price = 0
    realized_price = 0
    net = 0
    state = "exchangee"
  end  

  def return!
    update_attribute(:state, "returned")
    product.return! if product.returnable?
  end

  def modified?
    !state == "purchased"
  end

  def settled?
    state == "settled"
  end

  def self.find_by_order(order)
    return [] unless order.id?

    self.find_by_order_id(order.id).tap do |items|
      items.each { |item| item.order = order }
    end
  end

  def self.settle(items, settlement)
    if items.blank?
      logger.debug("AthenaItem.settle: No items to settle, returning")
      return
    end

    logger.debug("Settling items #{items.collect(&:id).join(',')}")
    patch(items, { :settlementId => settlement.id, :state => :settled })
  end

  private

    def self.patch(items, attributes)
      response = connection.put("/orders/items/patch/#{items.collect(&:id).join(",")}", attributes.to_json, self.headers)
      format.decode(response.body).map{ |attributes| new(attributes) }
    end

    def set_product_details_from(prod)
      self.product_id = prod.id
      self.product_type = prod.class.to_s
    end

    def set_prices_from(prod)
      self.price          = prod.price
      self.realized_price = prod.price - prod.class.fee
      self.net            = (self.realized_price - (self.realized_price * 0.035)).floor
    end

    def set_performance_from(prod)
      self.performance_id = prod.performance_id
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

    def find_order
      return if self.order_id.nil?

      begin
        AthenaOrder.find(self.order_id)
      rescue ActiveResource::ResourceNotFound
        update_attribute!(:order_id, nil)
        return nil
      end
    end
end
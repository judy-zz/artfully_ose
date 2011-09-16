class AthenaItem < AthenaResource::Base
  self.site = Artfully::Application.config.orders_component
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
    
    #FA
    attribute 'fs_project_id',  :string
    attribute 'is_noncash',     :string
    attribute 'is_stock',       :string
    attribute 'reversed_at',    :string
    attribute 'reversed_note',  :string
    attribute 'fs_available_on',:string
    attribute 'is_anonymous',   :string
    attribute 'nongift_amount',   :string
  end

  validates_presence_of :order_id, :product_type, :price, :realized_price, :net
  validates_inclusion_of :product_type, :in => %( AthenaTicket Donation )
  validate :product_type_exists

  def product_type_exists
    begin
      Kernel.const_get(product_type)
    rescue NameError
      errors.add(:product_type, "is not a valid type") unless valid_type
    end
  end

  def ticket?
    product_type == "AthenaTicket"
  end

  def donation?
    product_type == "Donation"
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
      logger.debug("AthenaItem.settle: No items to settle, returning")
      return
    end

    logger.debug("Settling items #{items.collect(&:id).join(',')}")
    patch(items, { :settlementId => settlement.id, :state => :settled })
  end

  def self.from_fa_donation(fa_donation, organization)    
    @item = AthenaItem.new
    @item.organization_id = organization.id
    @item.price = fa_donation.amount.to_f * 100
    @item.realized_price = fa_donation.amount.to_f * 100
    @item.net = (fa_donation.amount.to_f * 100) * 0.94
    @item.fs_project_id = fa_donation.fs_project_id
    @item.nongift_amount = fa_donation.nongift.to_f * 100
    @item.is_noncash = fa_donation.is_noncash
    @item.is_stock = fa_donation.is_stock
    @item.reversed_at = fa_donation.reversed_at
    @item.reversed_note = fa_donation.reversed_note
    @item.fs_available_on = fa_donation.fs_available_on
    @item.is_anonymous = fa_donation.is_anonymous
    
    return @item
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
        return nil
      end
    end
end
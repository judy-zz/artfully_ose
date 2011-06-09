class AthenaItem < AthenaResource::Base
  self.site = Artfully::Application.config.orders_component
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'items'
  self.collection_name = 'items'

  schema do
    attribute 'order_id',   :integer
    attribute 'product_type',  :string
    attribute 'product_id',    :string
    attribute 'price',      :integer
    attribute 'state',      :string
  end

  validates_presence_of :order_id, :product_type, :product_id, :price
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

  def product
    @product ||= find_product
  end

  def product=(prod)
    @product          = prod
    self.product_id   = prod.id
    self.product_type = prod.class.to_s
    self.price        = prod.price
  end

  def dup!
    self.class.new(attributes.reject { |key, value| %w( id ).include? key } )
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
    end
  end

  def return!
    update_attribute(:state, "returned")
    product.return! if product.returnable?
  end

  def self.find_by_order(order)
    return [] unless order.id?
    items = AthenaItem.find(:all, :params => {:orderId => "eq#{order.id}"} )
    items.each do |item|
      item.order = order
    end
    items
  end

  private

    def modified?
      !state.blank?
    end

    def find_product
      return if self.product_id.nil?

      begin
        klass = Kernel.const_get(product_type)
        klass.find(product_id)
      rescue NameError
        return nil
      rescue ActiveResource::ResourceNotFound
        update_attribute!(:product_id, nil)
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
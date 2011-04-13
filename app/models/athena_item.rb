class AthenaItem < AthenaResource::Base
  self.site = Artfully::Application.config.orders_component
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'items'
  self.collection_name = 'items'

  schema do
    attribute 'order_id',   :integer
    attribute 'item_type',  :string
    attribute 'item_id',    :string
    attribute 'price',      :integer
    attribute 'state',      :string
  end

  validates_presence_of :order_id, :item_type, :item_id, :price
  validates_inclusion_of :item_type, :in => %( AthenaTicket Donation )
  validate :item_type_exists

  def item_type_exists
    begin
      Kernel.const_get(item_type)
    rescue NameError
      errors.add(:item_type, "is not a valid type") unless valid_type
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

  def item
    @item ||= find_item
  end

  def item=(itm)
    @item, item_id = itm, itm.id
    item_type = itm.class
  end

  def refund_item
    new_attrs = attributes.reject { |key, value| %w( id ).include? key }
    new_attrs.merge!({:state => "refunded"})
    AthenaItem.new(new_attrs)
  end

  def returnable?
    !item.expired?
  end

  def return_item
    item.on_sale! if returnable?
  end

  def self.find_by_order(order)
    return [] unless order.id?
    AthenaItem.find(:all, :params => {:orderId => "eq#{order.id}"} )
  end

  private

    def find_item
      return if self.item_id.nil?

      begin
        klass = Kernel.const_get(item_type)
        klass.find(item_id)
      rescue NameError
        return nil
      rescue ActiveResource::ResourceNotFound
        update_attribute!(:item_id, nil)
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
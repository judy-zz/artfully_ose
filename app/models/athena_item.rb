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
  end

  validates_presence_of :order_id, :item_type, :item_id, :price

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

  def self.find_by_order(order)
    return [] if order.id.nil?
    AthenaItem.find(:all, :params => {:orderId => "eq#{order.id}"} )
  end

  private
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
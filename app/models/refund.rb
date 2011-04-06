class Refund
  def initialize(order, items)
    @order = order
    @items = items
  end

  def submit
    payment.refund!
    if @success = payment.refunded?
      create_refund_order
    end
  end

  def successful?
    @success || false
  end

  def refund_amount
    @amount ||= @items.collect(&:price).reduce(:+)
  end

  def refunded_items
    @items.size
  end

  private

  def payment
    @payment ||= @order.payment.tap do |payment|
      payment.amount = refund_amount
    end
  end

  def refund_items
    @items.map(&:refund!)
  end

  def create_refund_order
    refunded_items = @items.collect(&:refund_item)

    refund_order = AthenaOrder.new.tap do |refund_order|
      refund_order.for_organization @order.organization
      refund_order.person = @order.person
      refund_order.for_items @items
      refund_order.transaction_id = payment.transaction_id
      refund_order.parent = @order
    end

    refund_order.save!
  end
end
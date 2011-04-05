class Refund
  def initialize(order, items)
    @order = order
    @items = items
  end

  def submit
    payment.refund!
    if @success = payment.refunded?
      refund_items
      create_refund_order
    end
  end

  def successful?
    @success || false
  end

  def refund_amount
    @amount ||= @items.collect(&:price).reduce(:+)
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
  end
end
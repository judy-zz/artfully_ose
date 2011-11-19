class Refund
  attr_accessor :order, :items, :gateway_error_message

  def initialize(order, items)
    self.order = order
    self.items = items
  end

  def submit(options = {})
    should_return = options[:and_return] || false

    payment.refund!

    if @success = payment.refunded?
      items.each(&:return!) if should_return
      items.each(&:refund!)
      create_refund_order
    else
      puts payment.message
      @gateway_error_message = payment.message
    end
  end

  def successful?
    @success || false
  end

  def refund_amount
    @amount ||= items.collect(&:price).sum
  end

  private

  def payment
    @payment ||= order.payment.tap do |payment|
      payment.amount = refund_amount
    end
  end

  def create_refund_order
    refund_order = Order.new.tap do |refund_order|
      refund_order.person = order.person
      refund_order.transaction_id = payment.transaction_id
      refund_order.parent = order
      refund_order.for_organization order.organization
      refund_order.items = items.collect(&:to_refund)
    end

    refund_order.save!
  end
end
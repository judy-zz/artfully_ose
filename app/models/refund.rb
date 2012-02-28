class Refund
  attr_accessor :order, :refund_order, :items, :gateway_error_message

  def initialize(order, items)
    self.order = order
    self.items = items
  end

  def submit(options = {})
    return_items = options[:and_return] || false

    gateway = ActiveMerchant::Billing::BraintreeGateway.new(
      :merchant_id => Artfully::Application.config.BRAINTREE_MERCHANT_ID,
      :public_key  => Artfully::Application.config.BRAINTREE_PUBLIC_KEY,
      :private_key => Artfully::Application.config.BRAINTREE_PRIVATE_KEY
    )

    response = gateway.refund(refund_amount, order.transaction_id)
    @success = response.success?
    
    if @success
      items.each(&:return!) if return_items
      items.each(&:refund!)
      create_refund_order(response.authorization)
    else
      @gateway_error_message = response.message
    end
  end

  def successful?
    @success || false
  end

  def refund_amount
    @amount ||= items.collect(&:price).sum + (items.size * ((order.service_fee / order.items.reject{|item| item.price == 0}.size)))
  end

  private
    def create_refund_order(transaction_id = nil)
      @refund_order = RefundOrder.new
      @refund_order.person = order.person
      @refund_order.transaction_id = transaction_id
      @refund_order.parent = order
      @refund_order.for_organization order.organization
      @refund_order.items = items.collect(&:to_refund)
      @refund_order.save!
      @refund_order
    end
end
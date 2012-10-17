class Refund
  attr_accessor :order, :refund_order, :items, :gateway_error_message

  BRAINTREE_UNSETTLED_MESSAGE = "Cannot refund a transaction unless it is settled. (91506)"
  FRIENDLY_UNSETTLED_MESSAGE = "The processor cannot refund that transaction yet. Please try again in a few hours."

  def initialize(order, items)
    self.order = order
    self.items = items
  end

  def submit(options = {})
    return_items_to_inventory = options[:and_return] || false

    gateway = ActiveMerchant::Billing::BraintreeGateway.new(
      :merchant_id => Rails.application.config.braintree.merchant_id,
      :public_key  => Rails.application.config.braintree.public_key,
      :private_key => Rails.application.config.braintree.private_key
    )

    if refund_amount > 0
      response = gateway.refund(refund_amount, order.transaction_id)
      transaction_id = response.authorization
      @gateway_error_message = format_message(response.message)
      @success = response.success?
    else
      @success = true
    end
    
    if @success
      items.each { |i| i.return!(return_items_to_inventory) }
      items.each(&:refund!)
      create_refund_order(transaction_id)
    end
  end

  def successful?
    @success || false
  end

  #This is brittle, sure, but active merchant doens't pass along any processor codes so we have to match the whole stupid string
  def format_message(message)
    (message.eql? BRAINTREE_UNSETTLED_MESSAGE) ? FRIENDLY_UNSETTLED_MESSAGE : message
  end

  def refund_amount
    item_total + (number_of_non_free_items(items) * service_fee_per_item(order.items))
  end

  private
    def service_fee_per_item(itmz)
      #ternery operation solely to avoid dividing by zero
      number_of_non_free_items(itmz) == 0 ? 0 : (order.service_fee || 0) / number_of_non_free_items(itmz)
    end
  
    def item_total
      items.collect(&:price).sum
    end
  
    def number_of_non_free_items(itmz)
      itmz.reject{|item| item.price == 0}.size
    end
  
    def create_refund_order(transaction_id = nil)
      @refund_order = RefundOrder.new
      @refund_order.person = order.person
      @refund_order.transaction_id = transaction_id
      @refund_order.payment_method = order.payment_method
      @refund_order.parent = order
      @refund_order.for_organization order.organization
      @refund_order.items = items.collect(&:to_refund)
      @refund_order.save!
      @refund_order
    end
end
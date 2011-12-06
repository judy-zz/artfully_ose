class CreditCardPayment < AthenaResource::Base
  # A slimmed down version of Athena Payments for use in the Box Office

  self.site = Artfully::Application.config.payments_component
  self.element_name = Artfully::Application.config.payments_element_name
  
  def payment_method
    'Credit card'
  end
  
  attr_accessor :customer

  schema do
    attribute 'amount',         :string
    attribute 'credit_card',    :string
    attribute 'success',        :string
    attribute 'message',          :string
    attribute 'transaction_id', :string
  end

  def self.for_card_and_customer(card, customer)
    new(:credit_card => card).tap do |payment|
      payment.customer = customer
    end
  end

  def per_item_processing_charge
    lambda { |item| item.realized_price * 0.035 }
  end

  def requires_authorization?
    true
  end

  def requires_settlement?
    true
  end

  def approved?
    self.success == true
  end

  def rejected?
    self.success == false
  end

  def amount=(amount)
    return if amount.nil?
    # Convert from cents to dollars for the payment processor
    amount = amount.to_i / 100.00
    super(amount)
  end

  def reduce_amount_by(amount_in_cents)
    self.amount=((amount * 100) - amount_in_cents)
  end

  def authorize!
    connection.post( AthenaPayment::element_name + "/transactions/authorize", encode, self.class.headers).tap do |response|
      load_attributes_from_response(response)
    end
    approved?
  end
  alias :save :authorize!
  alias :save! :authorize!

  def settle!
    connection.post( AthenaPayment::element_name + "/transactions/settle", encode, self.class.headers).tap do |response|
      load_attributes_from_response(response)
    end
    approved?
  end

end
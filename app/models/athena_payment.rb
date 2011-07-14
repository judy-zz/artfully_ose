class AthenaPayment < AthenaResource::Base
  self.site = Artfully::Application.config.payments_component
  self.collection_name = 'payments'
  self.element_name = 'payments'

  validates_acceptance_of :user_agreement
  validates_numericality_of :amount, :greater_than_or_equal_to => 0
  validates_presence_of :billing_address

  validates_each :billing_address, :customer do |model, attr, value|
    model.errors.add(attr, "is invalid") unless model.send(attr).valid?
  end

  with_options :if => :credit_card_required? do |payment|
    payment.validates_presence_of :credit_card
    payment.validates_each :credit_card do |model, attr, value|
      model.errors.add(attr, "is invalid") unless model.send(attr).valid?
    end
  end

  def credit_card_required?
    amount.to_i > 0
  end

  schema do
    attribute 'amount', :string
    attribute 'billing_address', :string
    attribute 'credit_card', :string
    attribute 'customer', :string
    attribute 'success', :string
  end

  def load(attributes = [])
    @attributes['billing_address'] = AthenaAddress.new(attributes.delete('billing_address')) if attributes.has_key? 'billing_address'
    @attributes['credit_card'] = AthenaCreditCard.new(attributes.delete('athena_credit_card')) if attributes.has_key? 'athena_credit_card'
    @attributes['customer'] = AthenaCustomer.new(attributes.delete('athena_customer')) if attributes.has_key? 'athena_customer'
    super(attributes)
  end

  def customer
    @attributes['customer'] ||= AthenaCustomer.new
  end

  def billing_address
    @attributes['billing_address'] ||= AthenaAddress.new
  end

  def billing_address=(address)
    attributes['billing_address'] = address
  end

  def credit_card
    @attributes['credit_card'] ||= AthenaCreditCard.new
  end

  def credit_card=(credit_card)
    @attributes['credit_card'] = credit_card
  end

  def approved?
    self.success == true
  end
  alias :refunded? :approved?

  def rejected?
    self.success == false
  end

  def amount=(amount)
    return if amount.nil?
    # Convert from cents to dollars for the payment processor
    amount = amount.to_i / 100.00
    super(amount)
  end

  def authorize!
    connection.post("/athena/payments/transactions/authorize", encode, self.class.headers).tap do |response|
      load_attributes_from_response(response)
    end
    approved?
  end
  alias :save :authorize!
  alias :save! :authorize!

  def settle!
    connection.post("/athena/payments/transactions/settle", encode, self.class.headers).tap do |response|
      load_attributes_from_response(response)
    end
    approved?
  end

  def refund!
    connection.post("/athena/payments/transactions/refund", encode, self.class.headers).tap do |response|
      load_attributes_from_response(response)
    end
    refunded?
  end
end


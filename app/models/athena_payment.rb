class AthenaPayment < AthenaResource::Base
  self.site = Artfully::Application.config.payments_component
  self.headers["User-agent"] = "artful.ly"
  self.collection_name = 'payments'
  self.element_name = 'payments'

  validates_numericality_of :amount, :greater_than => 0
  validates_presence_of :billing_address, :credit_card

  validates_each :billing_address, :credit_card, :customer do |model, attr, value|
    model.errors.add(attr, "is invalid") unless model.send(attr).valid?
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

  def rejected?
    self.success == false
  end

  def authorize!
    connection.post("/payments/transactions/authorize", encode, self.class.headers).tap do |response|
      load_attributes_from_response(response)
    end
    approved?
  end
  alias :save :authorize!
  alias :save! :authorize!

  def settle!
    connection.post("/payments/transactions/settle", encode, self.class.headers).tap do |response|
      load_attributes_from_response(response)
    end
    approved?
  end
end


class Payment < AthenaResource::Base
  self.site = Artfully::Application.config.tickets_site
  self.headers["User-agent"] = "artful.ly"

  validates_numericality_of :amount, :greater_than => 0
  validates_presence_of :billing_address, :credit_card

  validates_each :billing_address, :credit_card, :customer do |model, attr, value|
    model.errors.add(attr, "is invalid") unless model.send(attr).valid?
  end

  schema do
    attribute 'amount', :string
    attribute 'billingAddress', :string
    attribute 'creditCard', :string
    attribute 'customer', :string

    attribute 'success', :string
  end

  def load(attributes)
    @attributes['billingAddress'] = Address.new(attributes.delete('billing_address')) if attributes.has_key? 'billing_address'
    @attributes['creditCard'] = CreditCard.new(attributes.delete('credit_card')) if attributes.has_key? 'credit_card'
    super(attributes)
  end

  def customer
    @attributes['customer'] ||= Customer.new
  end

  def billingAddress
    @attributes['billingAddress'] ||= Address.new
  end

  alias :billing_address :billingAddress

  def billing_address=(address)
    self.billingAddress = address
  end

  def creditCard
    @attributes['creditCard'] ||= CreditCard.new
  end

  alias :credit_card :creditCard

  def credit_card=(credit_card)
    self.creditCard = credit_card
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

  def settle!
    connection.post("/payments/transactions/settle", encode, self.class.headers).tap do |response|
      load_attributes_from_response(response)
    end
    approved?
  end
end

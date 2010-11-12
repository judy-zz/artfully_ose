class Athena::Payment < AthenaResource::Base
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
    @attributes['billingAddress'] = Athena::Payment::Address.new(attributes.delete('billing_address')) if attributes.has_key? 'billing_address'
    @attributes['creditCard'] = Athena::CreditCard.new(attributes.delete('credit_card')) if attributes.has_key? 'credit_card'
    super(attributes)
  end

  def customer
    @attributes['customer'] ||= Athena::Customer.new
  end

  def billingAddress
    @attributes['billingAddress'] ||= Athena::Payment::Address.new
  end

  alias :billing_address :billingAddress

  def billing_address=(address)
    self.billingAddress = address
  end

  def creditCard
    @attributes['creditCard'] ||= Athena::CreditCard.new
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

class Athena::Payment::Address
  include ActiveModel::Validations

  # Note: This is used to provide a more ruby-friendly set of accessors that will still serialize properly.
  def self.aliased_attr_accessor(*accessors)
    attr_reader :attributes
    accessors.each do |attr|
      attr = attr.to_s.camelize(:lower)
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{attr}() @attributes['#{attr}'] end
        def #{attr}=(#{attr}) @attributes['#{attr}'] = #{attr} end
        def #{attr.underscore}() @attributes['#{attr}'] end
        def #{attr.underscore}=(#{attr}) @attributes['#{attr}'] = #{attr} end
      RUBY_EVAL
    end
  end

  aliased_attr_accessor :firstName, :lastName, :company, :streetAddress1, :streetAddress2, :city, :state, :postalCode, :country
  validates_presence_of :first_name, :last_name, :street_address1, :city, :state, :postal_code


  def initialize(attrs = {})
    @attributes = {}.with_indifferent_access
    load(attrs)
  end

  def load(attrs)
    attrs.each do |attr, value|
      self.send(attr.to_s+'=', value)
    end
  end

  def as_json(options = nil)
    @attributes.as_json
  end
end



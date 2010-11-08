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
    @attributes['creditCard'] = Athena::Payment:: CreditCard.new(attributes.delete('credit_card')) if attributes.has_key? 'credit_card'
    super(attributes)
  end

  def customer
    @attributes['customer'] ||= Athena::Payment:: Customer.new
  end

  def billingAddress
    @attributes['billingAddress'] ||= Athena::Payment::Address.new
  end

  alias :billing_address :billingAddress

  def billing_address=(address)
    self.billingAddress = address
  end

  def creditCard
    @attributes['creditCard'] ||= Athena::Payment:: CreditCard.new
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

class Athena::Payment:: CreditCard
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

  aliased_attr_accessor :cardNumber, :expirationDate, :cardholderName, :cvv
  validates_presence_of :card_number, :expiration_date, :cardholder_name, :cvv

  def initialize(attrs = {})
    prepare_attr!(attrs) unless attrs.has_key? :expiration_date
    @attributes = {}.with_indifferent_access
    load(attrs)
  end

  def load(attrs)
    attrs.each do |attr, value|
      self.send(attr.to_s+'=', value)
    end
  end

  def as_json(options = nil)
    prepare_for_encode(@attributes).as_json
  end

  private
    def prepare_attr!(attributes)
      unless attributes.empty?
        day = attributes.delete('expiration_date(3i)')
        month = attributes.delete('expiration_date(2i)')
        year = attributes.delete('expiration_date(1i)')

        attributes['expiration_date'] = Date.parse("#{year}-#{month}-#{day}")
      end
    end

    def prepare_for_encode(attributes)
      hash = attributes.dup
      hash['expirationDate'] = self.expiration_date.strftime('%m/%Y')
      hash
    end
end

class Athena::Payment:: Customer
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

  aliased_attr_accessor :firstName, :lastName, :company, :phone, :email
  validates_presence_of :first_name, :last_name, :email

  def initialize(attrs = {})
    @attributes = {}.with_indifferent_access
    load(attrs)
  end

  # TODO: Check type of attrs, reject non-attributes
  def load(attrs)
    attrs.each do |attr, value|
      self.send(attr.to_s+'=', value)
    end
  end

  def as_json(options = nil)
    @attributes.as_json
  end
end

class CreditCard
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

  aliased_attr_accessor :number, :expirationDate, :cardholderName, :cvv
  validates_presence_of :number, :expiration_date, :cardholder_name, :cvv

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
    @attributes.as_json
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
end

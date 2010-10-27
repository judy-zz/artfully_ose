class CreditCard
  include ActiveModel::Validations

  # Note: This is used to provide a more ruby-friendly set of accessors that will still serialize properly.
  def self.aliased_attr_accessor(*accessors)
    attr_accessor(*accessors)
    accessors.each do |a|
      alias_method a.to_s.underscore, a
      alias_method "#{a}=".underscore, "#{a}="
    end
  end

  aliased_attr_accessor :number, :expirationDate, :cardholderName, :cvv
  validates_presence_of :number, :expiration_date, :cardholder_name, :cvv

  def initialize(attrs = {})
    prepare_attr!(attrs) unless attrs.has_key? :expiration_date
    load(attrs)
  end

  def load(attrs)
    attrs.each do |attr, value|
      self.send(attr.to_s+'=', value)
    end
  end

  def attributes
    hsh = {}
    %w( number expiration_date cardholder_name cvv ).each do |attr|
      hsh[attr.to_sym] = self.send(attr)
    end
    hsh
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

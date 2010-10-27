class Address
  include ActiveModel::Validations

  # Note: This is used to provide a more ruby-friendly set of accessors that will still serialize properly.
  def self.aliased_attr_accessor(*accessors)
    attr_accessor(*accessors)
    accessors.each do |a|
      alias_method a.to_s.underscore, a
      alias_method "#{a}=".underscore, "#{a}="
    end
  end

  aliased_attr_accessor :firstName, :lastName, :company,
                        :streetAddress, :city, :state, :postalCode, :country

  validates_presence_of :first_name, :last_name, :company,
                        :street_address, :city, :state, :postal_code, :country


  def initialize(attrs = {})
    load(attrs)
  end

  def load(attrs)
    attrs.each do |attr, value|
      self.send(attr.to_s+'=', value)
    end
  end

  def attributes
    hsh = {}
    %w( first_name last_name company street_address city state postal_code country ).each do |attr|
      hsh[attr.to_sym] = self.send(attr)
    end
    hsh
  end
end

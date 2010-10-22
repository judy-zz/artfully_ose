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
end

class Address
  include ActiveModel::Validations

  validates_presence_of :firstName, :lastName, :company,
                        :streetAddress, :city, :state, :postalCode, :country

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

end

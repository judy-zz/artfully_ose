class FA::Donor < FA::Base
  self.element_name = "donor"
  include ActiveModel::Serializers::Xml

  attr_accessor :email, :first_name, :last_name, :address1, :city, :state, :zip
  attr_accessor :anonymous

  def self.extract_from(payment)
    new.tap do |this|
      this.email      = payment.customer.email
      this.first_name = payment.customer.first_name
      this.last_name  = payment.customer.last_name
      this.address1   = payment.billing_address.street_address1
      this.city       = payment.billing_address.city
      this.state      = payment.billing_address.state
      this.zip        = payment.billing_address.postal_code
    end
  end

  def attributes
    {
      'email'        => email,
      'first_name'   => first_name,
      'last_name'    => last_name,
      'address1'     => address1,
      'city'         => city,
      'state'        => state,
      'zip'          => zip,
      'country'      => "US"
    }
  end
end
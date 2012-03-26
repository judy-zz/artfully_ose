class FA::Donor < FA::Base
  self.element_name = "donor"
  include ActiveModel::Serializers::Xml

  attr_accessor :email, :first_name, :last_name, :company_name, :address1, :city, :state, :zip, :country, :anonymous

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

  def has_keys?
    !email.blank?
  end

  def has_information?
    [ email, first_name, last_name ].any?
  end

  #order matters here, we use these in to_xml to adhered to the FA schema which is an xs:sequence
  #see: http://api.fracturedatlas.org/donations.xsd
  #Note: Ruby 1.8.7 doens't preserve hash order.  FA validation will fail.
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
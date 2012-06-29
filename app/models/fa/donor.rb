class FA::Donor < FA::Base
  self.element_name = "donor"
  # include ActiveModel::Serializers::Xml

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

  #options are ignored besides :indent, :builder, and :skip_instruct
  def to_xml(options = {})
    require 'builder'
    options[:indent] ||= 0
    xml = options[:builder] ||= ::Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.donor do
      attributes.each do |k,v|
        xml.tag!(k, v)
      end
    end
  end

  # order matters here because of the FA xsd sequence, see to_xml
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
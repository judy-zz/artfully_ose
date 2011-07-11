class FA::Donation < FA::Base
  schema do
    attribute 'amount',         :string
    attribute 'nongift',        :string
    attribute 'fs_project_id',  :string
  end

  attr_accessor :credit_card, :donor

  def self.from(donation, payment)
    new.tap do |this|
      this.amount        = donation.amount / 100.00
      this.fs_project_id = donation.organization.fa_project_id
      this.credit_card   = CreditCard.extract_from(payment)
      this.donor         = Donor.extract_from(payment)
    end
  end

  def to_xml(options = {})
    super({ :dasherize => false, :skip_types => true, :methods => [ 'donor', 'credit_card' ]}.merge(options))
  end

  private
    class CreditCard
      include ActiveModel::Serializers::Xml
      attr_accessor :number, :expiration, :zip, :code

      def self.extract_from(payment)
        new.tap do |this|
          this.number     = payment.credit_card.card_number
          this.expiration = payment.credit_card.expiration_date.strftime('%m/%Y')
          this.zip        = payment.billing_address.postal_code
          this.code       = payment.credit_card.cvv
        end
      end

      def attributes
        {
          'number'     => number,
          'expiration' => expiration,
          'zip'        => zip,
          'code'       => code
        }
      end
    end

    class Donor
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
end
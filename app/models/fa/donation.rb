class FA::Donation < FA::Base
  self.element_name = "donation"
  
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
      this.donor         = FA::Donor.extract_from(payment)
    end
  end

  def to_xml(options = {})
    super({ :dasherize => false, :skip_types => true, :methods => [ 'donor', 'credit_card' ]}.merge(options))
  end
  
  def self.find_by_member_id(fa_member_id)
    begin
      response = self.connection.get("/donations.xml?FsProject.member_id=#{fa_member_id}")
      collection = response[self.element_name]      
      collection.collect! { |record| instantiate_record(record, {}) }
    rescue ActiveResource::ResourceNotFound
      []
    end
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
end
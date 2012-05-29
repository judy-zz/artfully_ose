class FA::Donation < FA::Base
  self.element_name = "donation"
  
  schema do
    attribute 'amount',           :string
    attribute 'nongift',          :string
    attribute 'fs_project_id',    :string
    attribute 'date',             :string
    attribute 'check_no',         :string
    attribute 'is_noncash',       :string
    attribute 'is_stock',         :string
    attribute 'reversed_at',      :string
    attribute 'reversed_note',    :string
    attribute 'fs_available_on',  :string
    attribute 'is_anonymous',     :string
    attribute 'nongift',          :string
  end

  attr_accessor :credit_card, :donor

  def self.from(donation, payment)
    new.tap do |this|
      this.amount        = donation.amount / 100.00
      this.fs_project_id = donation.organization.fiscally_sponsored_project.fs_project_id
      this.credit_card   = CreditCard.extract_from(payment)
      this.donor         = FA::Donor.extract_from(payment)
    end
  end
  
  def to_xml(options = {})
    super({ :dasherize => false, :skip_types => true, :methods => [ 'donor', 'credit_card' ]}.merge(options))
  end
  
  def self.instantiate_record(record, options = {})
    donation = super(record, options)
    donation.donor = FA::Donor.new
    donation.donor.email = record['donor']['email']
    donation.donor.first_name = record['donor']['first_name']
    donation.donor.last_name = record['donor']['last_name']
    donation.donor.anonymous = record['donor']['anonymous']
    donation
  end
  
  def self.find_by_project_id(fa_project_id, since=nil)
    logger.info "Finding donations for FA project #{fa_project_id}"
    begin
      url = "/donations.xml?fs_project_id=#{fa_project_id}"
      url = url + "&updated_at-gt=#{CGI.escape(since.to_s)}" unless since.nil?
      logger.info "Getting donations from #{url}"
      donations = get_from(url)     
    rescue ActiveResource::ResourceNotFound => e
      logger.info "No donations found"
      []
    rescue ActiveResource::ServerError => e
      logger.info "Error getting donations."
      logger.info e.backtrace
      []
    end    
  end
  
  def self.find_by_member_id(fa_member_id, since=nil)
    logger.info "Finding donations for FA member #{fa_member_id}"
    begin
      url = "/donations.xml?FsProject.member_id=#{fa_member_id}"
      url = url + "&updated_at-gt=#{CGI.escape(since.to_s)}" unless since.nil?
      logger.info "Getting donations from #{url}"
      donations = get_from(url)  
    rescue ActiveResource::ResourceNotFound => e
      logger.info "No donations found"
      []
    rescue ActiveResource::ServerError => e
      logger.info "Error getting donations."
      logger.info e.backtrace
      []
    end
  end
  
  def self.get_from(url)
    instantiate_collection(Array.wrap(format.decode(self.connection.get(url).body)[self.element_name]))
  end

  def donor=(d)
    @donor=d
  end
  
  def donor
    @donor
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
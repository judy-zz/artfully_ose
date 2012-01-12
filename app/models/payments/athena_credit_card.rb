class AthenaCreditCard < AthenaResource::Base
  self.site = Artfully::Application.config.payments_component
  self.collection_name = 'cards'
  self.element_name = 'cards'

  schema do
    attribute 'cardholder_name',        :string
    attribute 'card_number',            :string
    attribute 'expiration_date',        :string
    attribute 'cvv',                    :string
    attribute 'customer', :string
  end

  validates :card_number, :presence => true
  validates :expiration_date, :presence => true
  validates :cvv, :numericality => true, :length => { :in => 3..4 }, :allow_blank => true
  validate :valid_luhn

  def valid_luhn
    errors.add(:card_number, " doesn't look like a valid credit card number.") unless passes_luhn?(card_number)
  end

  def passes_luhn?(num)
    odd = true
    num.to_s != "" &&
      num.to_i.to_s == num &&
      num.to_s.gsub(/\D/,'').reverse.split('').map(&:to_i).collect { |d|
      d *= 2 if odd = !odd
      d > 9 ? d - 9 : d
    }.sum % 10 == 0
  end

  def load(attributes = {})
    attributes = attributes.dup
    prepare_attr!(attributes) if needs_date_parse(attributes)
    prepare_customer!(attributes) if needs_customer(attributes)
    super
  end

  def encode(options = {})
    unless new_record?
      options[:rejections] = [] if options[:rejections].nil?
      options[:rejections] << 'card_number'
    end
    options[:attributes] = prepare_for_encode(attributes)
    super(options)
  end

  def valid?
    clean_card_number
    parse_card_number
    super
  end
  
  def self.from_swipe(swipe_data)
    card = AthenaCreditCard.new
    swiped_data = Swiper.parse swipe_data
    card.card_number = swiped_data.track1.primary_account_number
    card.cardholder_name = swiped_data.track1.cardholder_name
    card.expiration_date = swiped_data.track1.expiration_month + '/20' + swiped_data.track1.expiration_year    
    card
  end

  private
    def needs_date_parse(attrs = {})
      attrs.has_key? 'expiration_date(3i)' or attrs['expiration_date'].is_a? String
    end

    def prepare_attr!(attributes)
      #TODO: Debt; need to refector how we juggle the expirationDate as it uses a mm/yyyy format.
      unless attributes.blank?
        if attributes.has_key?('expiration_date(3i)')
          day = attributes.delete('expiration_date(3i)')
          month = attributes.delete('expiration_date(2i)')
          year = attributes.delete('expiration_date(1i)')
          attributes['expiration_date'] = Date.parse("#{year}-#{month}-#{day}")
        else
          attributes['expiration_date'] = Date.parse(attributes['expiration_date'])
        end
      end
    end

    def needs_customer(attributes)
      attributes.has_key? "customer"
    end

    def prepare_customer!(attributes)
      attributes['customer'] = AthenaCustomer.new(attributes.delete("customer"))
    end

    def prepare_for_encode(attributes)
      hash = attributes.dup
      attributes['expiration_date'] = Date.parse(self.expiration_date) if self.expiration_date.is_a? String
      hash['expiration_date'] = self.expiration_date.strftime('%m/%Y')
      hash
    end

    def clean_card_number
      card_number.gsub!(/-|\s/,"") unless card_number.nil?
    end

end

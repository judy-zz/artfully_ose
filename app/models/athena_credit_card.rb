class AthenaCreditCard < AthenaResource::Base

  self.site = Artfully::Application.config.tickets_site
  self.prefix = '/payments/'
  self.collection_name = 'cards'
  self.element_name = 'cards'

  schema do
    attribute 'cardholderName',        :string
    attribute 'cardNumber',            :string
    attribute 'expirationDate',        :string
    attribute 'cvv',                   :string

    attribute 'customer', :string
  end


  # Note: This is used to provide a more ruby-friendly set of accessors that will still serialize properly.
  def self.aliased_attr_accessor(*accessors)
    attr_reader :attributes
    accessors.each do |attr|
      attr = attr.to_s.camelize(:lower)
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{attr}()                     @attributes['#{attr}'] end
        def #{attr}=(#{attr})             @attributes['#{attr}'] = #{attr} end
        def #{attr.underscore}()          @attributes['#{attr}'] end
        def #{attr.underscore}=(#{attr})  @attributes['#{attr}'] = #{attr} end
      RUBY_EVAL
    end
  end

  aliased_attr_accessor :card_number, :expiration_date, :cardholder_name, :cvv
  validates_presence_of :card_number, :expiration_date, :cardholder_name, :cvv
  validates_numericality_of :card_number, :cvv
  validates_length_of :cvv, :in => 3..4
  validate :valid_luhn


  def valid_luhn
    errors.add(:card_number, "This doesn't look like a valid credit card.") unless passes_luhn?(card_number)
  end

  def passes_luhn?(num)
    odd = true
    num.to_s.gsub(/\D/,'').reverse.split('').map(&:to_i).collect { |d|
      d *= 2 if odd = !odd
      d > 9 ? d - 9 : d
    }.sum % 10 == 0
  end

  def initialize(attributes = {})
    prepare_attr!(attributes) if needs_date_parse(attributes)
    super
  end

  def load(attributes)
    fixed = {}
    attributes.each do |key, value|
      fixed[key.camelize(:lower)] = attributes.delete(key) if known_attributes.include?(key.camelize(:lower))
    end
    super(attributes.merge(fixed))
  end

  def as_json(options = nil)
    prepare_for_encode(@attributes).as_json
  end

  private
    def needs_date_parse(attrs)
      !attrs.blank? && ( attrs.has_key? 'expiration_date' or attrs.has_key? 'expirationDate' )
    end

    def prepare_attr!(attributes)
      #TODO: Debt; need to refector how we juggle the expirationDate as it uses a mm/yyyy format.
      unless attributes.blank?
        if attributes.has_key?('expiration_date(3i)')
          day = attributes.delete('expiration_date(3i)')
          month = attributes.delete('expiration_date(2i)')
          year = attributes.delete('expiration_date(1i)')
          attributes['expirationDate'] = Date.parse("#{year}-#{month}-#{day}")
        else
          attributes['expirationDate'] = Date.parse(attributes['expirationDate'])
        end
      end
    end

    def prepare_for_encode(attributes)
      hash = attributes.dup
      hash['expirationDate'] = self.expiration_date.strftime('%m/%Y')
      hash
    end
end

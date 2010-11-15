class Athena::CreditCard < AthenaResource::Base

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

  def initialize(attrs = {})
    prepare_attr!(attrs) if needs_date_parse(attrs)
    super
  end

  def load(attributes)
    fixed = {}
    attributes.each do |key, value|
      fixed[key.camelize(:lower)] = attributes.delete(key) if known_attributes.include?(key.camelize(:lower))
    end
    p attributes.merge(fixed)
    super(attributes.merge(fixed))
  end

  def as_json(options = nil)
    prepare_for_encode(@attributes).as_json
  end

  private
    def needs_date_parse(attrs)
      !attrs.empty? && !( attrs.has_key? :expiration_date or attrs.has_key? :expirationDate )
    end

    def prepare_attr!(attributes)
      p "ATTRIBUTES FOR PREP"
      p attributes
      unless attributes.empty?
        day = attributes.delete('expiration_date(3i)')
        month = attributes.delete('expiration_date(2i)')
        year = attributes.delete('expiration_date(1i)')

        attributes['expiration_date'] = Date.parse("#{year}-#{month}-#{day}")
      end
    end

    def prepare_for_encode(attributes)
      hash = attributes.dup
      hash['expirationDate'] = self.expiration_date.strftime('%m/%Y')
      hash
    end
end

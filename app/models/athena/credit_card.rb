class Athena::CreditCard < AthenaResource::Base

  self.site = Artfully::Application.config.tickets_site

  schema do
    attribute 'cardholder_name',         :string
    attribute 'card_number',            :string
    attribute 'expiration_date',        :string
    attribute 'cvv',                    :string
  end

  validates_presence_of :card_number, :expiration_date, :cardholder_name, :cvv

  def initialize(attrs = {})
    prepare_attr!(attrs) unless attrs.has_key? :expiration_date
    super
  end

  def as_json(options = nil)
    prepare_for_encode(@attributes).as_json
  end

  private
    def prepare_attr!(attributes)
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

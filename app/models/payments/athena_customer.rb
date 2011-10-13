class AthenaCustomer < AthenaResource::Base
  self.site = Artfully::Application.config.payments_component
  self.collection_name = 'customers'
  self.element_name = 'customers'

  schema do
    attribute 'first_name',  :string
    attribute 'last_name',   :string
    attribute 'company',    :string
    attribute 'phone',      :string
    attribute 'email',      :string
    attribute 'credit_cards', :string
  end

  def load(attributes)
    credit_cards = attributes.delete("credit_cards")
    unless credit_cards.blank?
      self.credit_cards = credit_cards.map do |credit_card|
        AthenaCreditCard.new(credit_card)
      end
    else
      self.credit_cards = []
    end

    super(attributes)
  end

  validates_presence_of :first_name, :last_name, :email

  def as_json(options = nil)
    @attributes.as_json
  end

end

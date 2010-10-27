class Payment < AthenaResource::Base
  self.site = Artfully::Application.config.tickets_site
  self.headers["User-agent"] = "artful.ly"

  validates_numericality_of :amount, :greater_than => 0
  validates_presence_of :shipping_address, :billing_address, :credit_card

  validates_each :shipping_address, :billing_address, :credit_card, :customer do |model, attr, value|
    model.errors.add(attr, "is invalid") unless model.send(attr).valid?
  end


  schema do
    attribute 'amount', :string
    attribute 'shipping_address', :string
    attribute 'billing_address', :string
    attribute 'credit_card', :string
  end

  def load(attributes)
    @attributes['shipping_address'] = Address.new(attributes.delete('shipping_address')) if attributes.has_key? 'shipping_address'
    @attributes['billing_address'] = Address.new(attributes.delete('billing_address')) if attributes.has_key? 'billing_address'
    super(attributes)
  end
end

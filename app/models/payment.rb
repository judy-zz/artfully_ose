class Payment < AthenaResource::Base
  self.site = Artfully::Application.config.tickets_site
  self.headers["User-agent"] = "artful.ly"

  validates_numericality_of :amount, :greater_than => 0
  validates_presence_of :shipping_address, :billing_address, :credit_card

  validates_each :shipping_address, :billing_address, :credit_card do |model, attr, value|
    model.errors.add(attr, "is invalid") unless model.send(attr).valid?
  end


  schema do
    attribute 'amount', :string
    attribute 'shipping_address', :string
    attribute 'billing_address', :string
    attribute 'credit_card', :string
  end

  def shipping_address=(address_or_hash)
    if address_or_hash.kind_of? Address
      super(address_or_hash)
    elsif
      super(Address.new(address_or_hash))
    end
  end

  def billing_address=(address_or_hash)
    if address_or_hash.kind_of? Address
      super(address_or_hash)
    elsif
      super(Address.new(address_or_hash))
    end
  end

  def credit_card=(credit_card_or_hash)
    if credit_card_or_hash.kind_of? CreditCard
      super(credit_card_or_hash)
    elsif
      super(CreditCard.new(credit_card_or_hash))
    end
  end
end

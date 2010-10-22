class Payment < AthenaResource::Base

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
end

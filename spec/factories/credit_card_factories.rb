Factory.define :credit_card, :default_strategy => :build do |cc|
  cc.number '1234 1234 1234 1234'
  cc.expiration_date '10/2010'
  cc.cardholder_name "John Smith"
  cc.cvv "224"
end

Factory.define :address, :class => AthenaAddress, :default_strategy => :build do |a|
  a.first_name      { Faker::Name.first_name }
  a.last_name       { Faker::Name.last_name }
  a.company         { Faker::Company.name }
  a.street_address1 { Faker::Address.street_address }
  a.street_address2 { Faker::Address.secondary_address }
  a.city            { Faker::Address.city }
  a.state           { Faker::Address.us_state }
  a.postal_code     { Faker::Address.zip_code }
  a.country         "United States"
end

Factory.sequence :credit_card_number do
  %w( 4111111111111111
      4005519200000004
      4009348888881881
      4012000033330026
      4012000077777777
      4012888888881881
      4217651111111119
      4500600000000061
      5555555555554444
      378282246310005
      371449635398431
      6011111111111117
      3530111333300000 ).rand
end

Factory.define :credit_card, :class => AthenaCreditCard, :default_strategy => :build do |cc|
  cc.card_number { Factory.next(:credit_card_number) }
  cc.expiration_date { Date.today }
  cc.cardholder_name { Faker::Name.name }
  cc.cvv "123"
end

Factory.define :credit_card_with_id, :parent => :credit_card do |cc|
  cc.id { UUID.new.generate }
  cc.after_build do |card|
    FakeWeb.register_uri(:post, "http://localhost/payments/cards/.json", :body => card.encode)
    FakeWeb.register_uri(:get, "http://localhost/payments/cards/#{card.id}.json", :body => card.encode)
  end
end

Factory.sequence :customer_id do |n|
  "#{n}"
end

Factory.define :customer, :class => AthenaCustomer, :default_strategy => :build do |c|
  c.first_name  { Faker::Name.first_name }
  c.last_name   { Faker::Name.last_name }
  c.phone       { Faker::PhoneNumber.phone_number }
  c.email       { Faker::Internet.email }
end

Factory.define :customer_with_id, :parent => :customer do |c|
  c.id { Factory.next :customer_id }
  c.after_build do |customer|
    FakeWeb.register_uri(:post, "http://localhost/payments/customers/.json", :body => customer.encode)
    FakeWeb.register_uri(:get, "http://localhost/payments/customers/#{customer.id}.json", :body => customer.encode)
  end
end

Factory.define :customer_with_credit_cards, :parent => :customer_with_id do |c|
  c.credit_cards { [ Factory(:credit_card) ] }
end
Factory.define :payment, :class => AthenaPayment, :default_strategy => :build do |p|
  p.amount 100
  p.billing_address { Factory(:address) }
  p.credit_card { Factory(:credit_card) }
  p.customer { Factory(:customer) }
  p.transaction_id "j59qrb"
end

Factory.sequence :id do |n|
  "#{n}"
end

Factory.define :address, :class => Athena::Payment::Address, :default_strategy => :build do |a|
  a.first_name      { Faker::Name.first_name }
  a.last_name       { Faker::Name.last_name }
  a.company         { Faker::Company.name }
  a.street_address1 { Faker::Address.street_address }
  a.street_address2 { Faker::Address.secondary_address }
  a.city            { Faker::Address.city }
  a.state           { Faker::Address.us_state }
  a.postal_code     { Faker::Address.zip_code }
  a.country         { Faker::Address.country }
end

Factory.define :payment, :class => Athena::Payment, :default_strategy => :build do |p|
  p.amount 100
  p.billing_address { Factory(:address) }
  p.credit_card { Factory(:credit_card) }
  p.customer { Factory(:customer) }
end

Factory.define :payment_with_id, :class => Athena::Payment, :default_strategy => :build do |p|
  p.id { Factory.next :id }
end

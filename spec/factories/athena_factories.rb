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

Factory.define :athena_chart, :default_strategy => :build do |c|
  c.name 'test chart'
end

Factory.define :athena_event, :default_strategy => :build do |e|
  e.name "Some Event"
  e.venue "Some Venue"
  e.producer "Some Producer"
  e.chart { Factory(:athena_chart)}
end

Factory.sequence :performance_datetime do |n|
  DateTime.strptime("2011-03-#{n}T10:10:00-04:00")
end

Factory.define :athena_performance, :default_strategy => :build do |p|
  p.chart { Factory(:athena_chart) }
  p.event { Factory(:athena_event) }
  p.datetime Factory.next :performance_datetime
end


Factory.sequence :number do
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
  cc.card_number { Factory.next(:number) }
  cc.expiration_date { Date.today }
  cc.cardholder_name { Faker::Name.name }
  cc.cvv "123"
end

Factory.define :credit_card_with_id, :parent => :credit_card do |cc|
  cc.id { UUID.new.generate }
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
end

Factory.define :customer_with_credit_cards, :parent => :customer_with_id do |c|
  c.credit_cards { [ Factory(:credit_card) ] }
end

Factory.define :lock, :class => AthenaLock, :default_strategy => :build do |t|
  t.id { UUID.new.generate }
end

Factory.define :unexpired_lock, :parent => :lock, :default_strategy => :build do |t|
  t.lockExpires { 1.week.from_now }
end

Factory.define :expired_lock, :parent => :lock, :default_strategy => :build do |t|
  t.lockExpires { 1.week.ago }
end

Factory.define :payment, :class => AthenaPayment, :default_strategy => :build do |p|
  p.amount 100
  p.billing_address { Factory(:address) }
  p.credit_card { Factory(:credit_card) }
  p.customer { Factory(:customer) }
end

Factory.sequence :ticket_id do |n|
  "#{n}"
end

Factory.define :ticket, :class => AthenaTicket, :default_strategy => :build do |t|
  t.event { Faker::Lorem.words(2).join(" ") }
  t.venue { Faker::Lorem.words(2).join(" ") + " Theatre"}
  t.performance { DateTime.now }
  t.sold false
  t.price "50.00"
end

Factory.define :ticket_with_id, :parent => :ticket, :default_strategy => :build do |t|
  t.id { Factory.next :ticket_id }
end
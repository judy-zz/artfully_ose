Factory.sequence :id do |n|
  "#{n}"
end

Factory.define :address, :class => Athena::Payment::Address, :default_strategy => :build do |a|
  a.first_name  "First"
  a.last_name "Last"
  a.company "Company"
  a.street_address1 "Street Address"
  a.street_address2 "Apt 1"
  a.city "City"
  a.state "State"
  a.postal_code "12345"
  a.country "Country"
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

Factory.sequence :id do |n|
  "#{n}"
end

Factory.define :customer, :class => AthenaCustomer, :default_strategy => :build do |c|
  c.first_name  { Faker::Name.first_name }
  c.last_name   { Faker::Name.last_name }
  c.phone       { Faker::PhoneNumber.phone_number }
  c.email       { Faker::Internet.email }
end

Factory.define :customer_with_id, :parent => :customer do |c|
  c.id { Factory.next :id }
end

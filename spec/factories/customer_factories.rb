Factory.define :customer, :class => Athena::Customer, :default_strategy => :build do |a|
  a.first_name  { Faker::Name.first_name }
  a.last_name   { Faker::Name.last_name }
  a.phone       { Faker::PhoneNumber.phone_number }
  a.email       { Faker::Internet.email }
end


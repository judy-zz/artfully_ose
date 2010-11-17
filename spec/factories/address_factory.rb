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

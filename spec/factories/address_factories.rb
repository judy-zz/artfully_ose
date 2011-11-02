Factory.define(:address) do |a|
  a.address1        { Faker::Address.street_address }
  a.address2        { Faker::Address.secondary_address }
  a.city            { Faker::Address.city }
  a.state           { Faker::Address.us_state }
  a.zip             { Faker::Address.zip_code }
  a.country         "United States"
end
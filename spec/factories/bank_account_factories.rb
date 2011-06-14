Factory.define(:bank_account) do |ba|
  ba.routing_number "111111118"
  ba.number         "3215240125"
  ba.type           "Personal Checkin"
  ba.name           "Joe Smith"
  ba.address        "248 W 35th St"
  ba.city           "New York"
  ba.state          "NY"
  ba.zip            "12345"
  ba.phone          "123-789- 4568"
end
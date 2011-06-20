Factory.define(:bank_account) do |ba|
  ba.routing_number "111111118"
  ba.number         "32152401253215240125"
  ba.account_type   "Personal Checking"
  ba.name           "Joe Smith"
  ba.address        "248 W 35th St"
  ba.city           "New York"
  ba.state          "NY"
  ba.zip            "12345"
  ba.phone          "123-789-4568"
end
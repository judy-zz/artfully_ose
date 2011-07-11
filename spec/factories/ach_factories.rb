Factory.define(:ach_account, :default_strategy => :build, :class => ACH::Account) do |account|
  account.routing_number  "111111118"
  account.number          "3215240125"
  account.type            "Business Checking"
end

Factory.define(:ach_customer, :default_strategy => :build, :class => ACH::Customer) do |customer|
  customer.id       "someCustID"
  customer.name     "John Doe"
  customer.address  "1234 Main St"
  customer.city     "Columbia"
  customer.state    "MD"
  customer.zip      "21046"
  customer.phone    "123-789-4568"
end
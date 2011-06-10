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

Factory.define(:ach_transaction, :default_strategy => :build, :class => ACH::Transaction) do |transaction|
  transaction.login_id       "eFco0UJyK8Tm"
  transaction.key            "7002b9ca57d92a41"
  transaction.type           "Debit"
  transaction.effective_date "01/01/2010"
  transaction.amount         "1.23"
  transaction.check_number   "8714"
  transaction.memo           "Memo!"
  transaction.secc_type      "CCD"
end
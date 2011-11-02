Given /^I can save Credit Cards to ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/payments/cards.json", :status => 200)
end

Given /^I can authorize Credit Cards in ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/payments/transactions/authorize", :body => "{ success:true, transaction_id:'j59qrb' }")
end

Given /^I can settle Credit Cards in ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/payments/transactions/settle", :body => "{ success : true }")
end

Given /^I can refund tickets through ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/payments/transactions/refund", :body => "{ success : true }")
end

Given /^I can save Customers to ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/payments/customers.json", :body => Factory(:customer_with_id).encode)
end
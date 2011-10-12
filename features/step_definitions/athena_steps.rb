Given /^ATHENA is up and running$/ do
  FakeWeb.allow_net_connect = false
end

Given /^I can save Tickets to ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/athena/tickets.json", :status => 200)
end

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

Given /^I can get Tickets from ATHENA$/ do
  FakeWeb.register_uri(:get, %r|http://localhost/athena/tickets/\.json|, :body => "[]")
end

Given /^I can lock Tickets in ATHENA$/ do
  FakeWeb.register_uri(:post, %r|http://localhost/athena/locks/\.json|, :body => Factory(:lock).encode)
end

Given /^I can save People to ATHENA$/ do
  FakeWeb.register_uri(:post, 'http://localhost/athena/people.json', :body => Factory(:person).encode )
end

Given /^I can save purchase actions in ATHENA$/ do
  FakeWeb.register_uri(:post, 'http://localhost/athena/actions.json', :body => Factory(:purchase_action).encode )
end

Given /^I can save Orders in ATHENA$/ do
  FakeWeb.register_uri(:post, 'http://localhost/athena/orders.json', :body => Factory(:order).encode )
  FakeWeb.register_uri(:post, 'http://localhost/athena/items.json', :body => Factory(:item).encode )
  FakeWeb.register_uri(:get, %r|http://localhost/athena/items.json.*|, :body => "[]")
end

Given /^the following tickets exist in ATHENA:$/ do |table|
  body = []
  table.hashes.each do |hash|
    body << ticket = Factory(:ticket_with_id, hash)
  end
  FakeWeb.register_uri(:get, %r|http://localhost/athena/tickets.json\?.*$|, :body => body.to_json)
end


Then /^the last request to ATHENA should include "([^"]*)"$/ do |exp|
  FakeWeb.last_request =~ exp
end


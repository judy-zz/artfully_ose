Given /^ATHENA is up and running$/ do
  FakeWeb.allow_net_connect = false
end

Given /^I can save Tickets to ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/tix/tickets/.json", :status => [ 200 ] )
end

Given /^I can save Credit Cards to ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/payments/cards/.json", :status => [ 200 ] )
end

Given /^I can authorize Credit Cards in ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/payments/transactions/authorize", :status => [ 200 ], :body => "{ success : true }" )
end

Given /^I can settle Credit Cards in ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/payments/transactions/settle", :status => [ 200 ], :body => "{ success : true }" )
end

Given /^I can save Customers to ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/payments/customers/.json", :status => [ 200 ], :body => Factory(:customer_with_id).encode)
end

Given /^I can get Tickets from ATHENA$/ do
  FakeWeb.register_uri(:get, %r|http://localhost/tix/tickets/\.json|, :status => [ 200 ], :body => "[]")
end

Given /^I can lock Tickets in ATHENA$/ do
  FakeWeb.register_uri(:post, %r|http://localhost/tix/meta/locks/\.json|, :status => [ 200 ], :body => Factory(:lock).encode)
end

Given /^I can save People to ATHENA$/ do
  FakeWeb.register_uri(:post, 'http://localhost/people/people/.json', :status => 200, :body => Factory(:athena_person_with_id).encode )
end

Given /^the following tickets exist in ATHENA:$/ do |table|
  body = []
  table.hashes.each do |hash|
    body << ticket = Factory(:ticket_with_id, hash)
  end
  FakeWeb.register_uri(:get, %r|http://localhost/tix/tickets/.json\?.*$|, :status => 200, :body => body.to_json)
end


Then /^the last request to ATHENA should include "([^"]*)"$/ do |exp|
  FakeWeb.last_request =~ exp
end


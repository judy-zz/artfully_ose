Given /^ATHENA is up and running$/ do
  FakeWeb.allow_net_connect = false
end

Given /^I can save Tickets to ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/tickets/.json", :status => [ 200 ] )
end

Given /^I can get Tickets from ATHENA$/ do
  FakeWeb.register_uri(:get, %r|http://localhost/tickets/\.json|, :status => [ 200 ], :body => "[]")
end

Then /^the last request to ATHENA should include "([^"]*)"$/ do |exp|
  FakeWeb.last_request =~ exp
end


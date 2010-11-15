Given /^ATHENA is up and running$/ do
  FakeWeb.allow_net_connect = false
end

Given /^I can save Tickets to ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/tickets/.json", :status => [ 200 ] )
end

Given /^I can get Tickets from ATHENA$/ do
  FakeWeb.register_uri(:get, %r|http://localhost/tickets/\.json|, :status => [ 200 ], :body => "[]")
end

Given /^I can lock Tickets in ATHENA$/ do
  FakeWeb.register_uri(:post, %r|http://localhost/tickets/locks/\.json|, :status => [ 200 ], :body => Factory(:unexpired_lock).encode)
end

Given /^I have found the following tickets for purchase$/ do |table|
  body = []
  ids = []
  table.hashes.each do |hash|
    ticket = Factory(:ticket, hash)
    body << ticket
    ids << ticket.id
    FakeWeb.register_uri(:get, %r|http://localhost/tickets/#{ticket.id}\.json|, :status => [ 200 ], :body => ticket.encode)
  end
  FakeWeb.register_uri(:get, %r|http://localhost/tickets/.json\?.*$|, :status => 200, :body => body.to_json)
  FakeWeb.register_uri(:get, %r|http://localhost/tickets/locks/.*\.json|, :status => [ 200 ], :body => Factory(:unexpired_lock, :tickets => ids).encode)
end

Given /^the following tickets exist in ATHENA:$/ do |table|
  body = []
  table.hashes.each do |hash|
    body << ticket = Factory(:ticket, hash)
    FakeWeb.register_uri(:get, %r|http://localhost/tickets/#{ticket.id}\.json|, :status => [ 200 ], :body => ticket.encode)
  end
  FakeWeb.register_uri(:get, %r|http://localhost/tickets/.json\?.*$|, :status => 200, :body => body.to_json)
end


Then /^the last request to ATHENA should include "([^"]*)"$/ do |exp|
  FakeWeb.last_request =~ exp
end



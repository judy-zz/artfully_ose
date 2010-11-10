Given /^ATHENA is up and running$/ do
  FakeWeb.allow_net_connect = false
end

Given /^I can save Tickets to ATHENA$/ do
  FakeWeb.register_uri(:post, "http://localhost/tickets/.json", :status => [ 200 ] )
end

Given /^I can get Tickets from ATHENA$/ do
  FakeWeb.register_uri(:get, %r|http://localhost/tickets/\.json|, :status => [ 200 ], :body => "[]")
end

Given /^I have found the following tickets for purchase$/ do |tickets|
  body = []
  tickets.each do |ticket|
    body << Factory(:ticket, {:id=>ticket['id'], :venue=>ticket['venue'], :event=>ticket['event'], :performance=>['performance']})
  end
  FakeWeb.register_uri(:get, %r|http://localhost/tickets/\?.*$|, :status => [ 200 ], :body => body.encode)
  visit tickets_path
  fill_in("Performance", :with => tickets.first['performance'])
  click_button("Search")
end

Then /^the last request to ATHENA should include "([^"]*)"$/ do |exp|
  FakeWeb.last_request =~ exp
end



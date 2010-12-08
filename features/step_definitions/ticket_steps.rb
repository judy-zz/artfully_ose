Given /^I have found (\d+) tickets to "([^"]*)" at "([^"]*)" for \$(\d+)$/ do |quantity, event, venue, price|
  body = []
  ids = []
  quantity.to_i.times do
    ticket = Factory(:ticket_with_id, :event => event, :venue => venue, :price => price)
    body << ticket
    ids << ticket.id
  end
  FakeWeb.register_uri(:get, "http://localhost/tix/tickets/.json?price=eq#{price}&_limit=#{quantity}", :status => 200, :body => body.to_json)
  FakeWeb.register_uri(:any, %r|http://localhost/tix/meta/locks/.*\.json|, :status => [ 200 ], :body => Factory(:unexpired_lock, :tickets => ids).encode)

  Given %Q{I search for #{quantity} tickets for $#{price}}
end

Given /^I search for (\d+) tickets for \$(\d+)$/ do |quantity, price|
  Given "I am on the tickets page"
  And %Q{I fill in "price" with "eq#{price}"}
  And %Q{I fill in "limit" with "#{quantity}"}
  And %Q{I press "Search"}
end

Given /^I have found the following tickets by searching for$/ do |table|
  body = []
  ids = []
  table.hashes.each do |hash|
    ticket = Factory(:ticket_with_id, hash)
    body << ticket
    ids << ticket.id
  end
  FakeWeb.register_uri(:get, %r|http://localhost/tix/tickets/.json\?.*$|, :status => 200, :body => body.to_json)
  FakeWeb.register_uri(:get, %r|http://localhost/tix/meta/locks/.*\.json|, :status => [ 200 ], :body => Factory(:unexpired_lock, :tickets => ids).encode)
end


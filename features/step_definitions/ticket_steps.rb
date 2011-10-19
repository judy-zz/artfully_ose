Then /^I should see (\d+) tickets to "([^"]*)" at "([^"]*)" for \$(\d+)$/ do |quantity, event, venue, price|
  Then %{I should see "#{event}"}
  Then %{I should see "#{venue}"}
  Then %{I should see "#{price}"}
  Then %{I should see #{quantity} tickets}
end

Then /^I should see (\d+) tickets?$/ do |quantity|
  #+1 for the service fee
  page.should have_xpath("//li[@class='ticket']", :count => quantity.to_i+1)
end

Given /^I search for (\d+) tickets for \$(\d+)$/ do |quantity, price|
  Given "I am on the tickets page"
  And %Q{I fill in "price" with "eq#{price}"}
  And %Q{I fill in "limit" with "#{quantity}"}
  And %Q{I press "Search"}
end

Given /^there are (\d+) tickets to "([^"]*)" at "([^"]*)" for (\d+)$/ do |quantity, event, venue, price|
  quantity.to_i.times do |i|
    ticket = Factory(:ticket, :event => event, :venue => venue, :price => price)
    body << ticket
    ids << ticket.id
  end
  FakeWeb.register_uri(:get, %r|http://localhost/athena/tickets.json\?.*$|, :body => body.to_json)
  FakeWeb.register_uri(:get, %r|http://localhost/athena/locks/.*\.json|, :body => Factory(:lock, :tickets => ids).encode)
end


Given /^I have found the following tickets by searching for$/ do |table|
  body = []
  ids = []
  table.hashes.each do |hash|
    ticket = Factory(:ticket, hash)
    body << ticket
    ids << ticket.id
  end
  FakeWeb.register_uri(:get, %r|http://localhost/athena/tickets.json\?.*$|, :body => body.to_json)
  FakeWeb.register_uri(:get, %r|http://localhost/athena/locks/.*\.json|, :body => Factory(:lock, :tickets => ids).encode)
end

Given /^I check the (\d+)(?:st|nd|rd|th) ticket to put on sale$/ do |pos|
  within(:xpath, "(//div[@id='on-sale']/form/ul/li)[#{pos.to_i}]") do
    check("selected_tickets[]")
  end
  FakeWeb.register_uri(:put, %r|http://localhost/athena/tickets/patch/.*|, :body => "[]")
  @performance.tickets[pos.to_i - 1].state = "on_sale"
  body = @performance.tickets.collect { |t| t.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/athena/tickets.json?performanceId=eq#{@performance.id}", :body => "[#{body}]")
end

Then /^the (\d+)(?:st|nd|rd|th) ticket should be on sale$/ do |pos|
  within(:xpath, "//table/tbody/tr[#{pos.to_i}]") do
    Then %Q{I should see "On Sale"}
  end
end

Given /^I check the (\d+)(?:st|nd|rd|th) ticket to take off sale$/ do |pos|
  within(:xpath, "(//div[@id='off-sale']/form/ul/li)[#{pos.to_i}]") do
    check("selected_tickets[]")
  end
  FakeWeb.register_uri(:put, %r|http://localhost/athena/tickets/patch/.*|, :body => "[]")
  @performance.tickets[pos.to_i - 1].state = "off_sale"
  body = @performance.tickets.collect { |t| t.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/athena/tickets.json?performanceId=eq#{@performance.id}", :body => "[#{body}]")

end

Then /^the (\d+)st ticket should be off sale$/ do |pos|
  within(:xpath, "//table/tbody/tr[#{pos.to_i}]") do
    Then %Q{I should see "Off Sale"}
  end
end

Given /^there are (\d+) tickets available$/ do |quantity|
  quantity = quantity.to_i
  Given "I can lock Tickets in ATHENA"
  tickets = current_performances.first.tickets.take(quantity)
  body = "[#{tickets.collect(&:encode).join(',')}]"
  FakeWeb.register_uri(:get, %r|http://localhost/athena/tickets/available\.json\?.*_limit=\d+&.*&state=on_sale.*|, :body => body)
end
Then /^I should see (\d+) tickets to "([^"]*)" at "([^"]*)" for \$(\d+)$/ do |quantity, event, venue, price|
  Then %{I should see "#{event}"}
  Then %{I should see "#{venue}"}
  Then %{I should see "#{price}"}
  Then %{I should see #{quantity} tickets}
end

Then /^I should see (\d+) tickets?$/ do |quantity|
  #+1 for the service fee
  page.should have_xpath("//li[@class='ticket']", :count => quantity.to_i * 2)
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
end


Given /^I have found the following tickets by searching for$/ do |table|
  body = []
  ids = []
  table.hashes.each do |hash|
    ticket = Factory(:ticket, hash)
    body << ticket
    ids << ticket.id
  end
end

Given /^I check the (\d+)(?:st|nd|rd|th) ticket to put on sale$/ do |pos|
  within(:xpath, "(//div[@id='on-sale']/form/ul/li)[#{pos.to_i}]") do
    check("selected_tickets[]")
  end
  @show.tickets[pos.to_i - 1].state = "on_sale"
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
  @show.tickets[pos.to_i - 1].state = "off_sale"
end

Then /^the (\d+)st ticket should be off sale$/ do |pos|
  within(:xpath, "//table/tbody/tr[#{pos.to_i}]") do
    Then %Q{I should see "Off Sale"}
  end
end

Given /^there are (\d+) tickets available$/ do |quantity|
  quantity = quantity.to_i
  Given "I can lock Tickets in ATHENA"
  tickets = current_shows.first.tickets.take(quantity)
end
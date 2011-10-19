When /^I delete the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |pos|
  current_performances.delete_at(pos.to_i - 1)
  within(:xpath, "(//ul[@id='of_performances']/li)[#{pos.to_i}]") do
    click_link "Delete"
  end
end

When /^I view the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |pos|
  @performance = current_performances[pos.to_i - 1]
  within(:xpath, "(//ul[@id='of_performances']/li)[#{pos.to_i}]") do
    click_link "performance-datetime"
  end
end

Then /^I should see (\d+) [Pp]erformances$/ do |count|
  page.should have_xpath("//ul[@id='of_performances']/li", :count => count.to_i)
end

Given /^the (\d+)(?:st|nd|rd|th) [Pp]erformance has had tickets created$/ do |pos|
  current_performances[pos.to_i - 1].state = "built"
  performance = current_performances[pos.to_i - 1]
  tickets = 5.times.collect { Factory(:ticket, :event_id => current_event.id, :peformance_id => performance.id) }
end

Given /^the (\d+)(?:st|nd|rd|th) [Pp]erformance is on sale$/ do |pos|
  current_performances[pos.to_i - 1].state = "on_sale"
  performance = current_performances[pos.to_i - 1]
  tickets = performance.tickets
  tickets.each { |ticket| ticket.state = "on_sale" }
end

Then /^I should see not be able to delete the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |pos|
  page.should have_no_xpath "(//tr[position()=#{pos.to_i}]/td[@class='actions']/a[@title='Delete'])"
end

Then /^I should see not be able to edit the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |pos|
  page.should have_no_xpath "(//tr[position()=#{pos.to_i}]/td[@class='actions']/a[@title='Edit'])"
end

Given /^a user@example.com named "([^"]*)" buys (\d+) tickets from the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |name, wanted, pos|
  fname, lname = name.split(" ")
  customer = Factory(:person, :first_name => fname, :last_name => lname)

  performance = current_performances[pos.to_i - 1]
  tickets = performance.tickets
  tickets.reject { |t| t.state == "sold" }.first(wanted.to_i).each do |ticket|
    ticket.buyer = customer
    ticket.state = "sold"
  end
end

When /^I search for the patron named "([^"]*)" email "([^"]*)"$/ do |name, email|
  fname, lname = name.split(" ")
  customer = Factory(:person, :first_name => fname, :last_name => lname, :email=>email, :organization_id => @current_user.current_organization.id)
  When %{I fill in "Search" with "#{email}"}
  And %{I press "Search"}
end

When /^I confirm comp$/ do
  customer = Factory(:person)
  ticket = Factory(:ticket)
  And %{I press "Confirm"}
end

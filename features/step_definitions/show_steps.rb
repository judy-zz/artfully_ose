When /^I delete the (\d+)(?:st|nd|rd|th) [Ss]how$/ do |pos|
  current_shows.delete_at(pos.to_i - 1)
  within(:xpath, "(//ul[@id='of_shows']/li)[#{pos.to_i}]") do
    click_link "Delete"
  end
end

When /^I view the (\d+)(?:st|nd|rd|th) [Ss]how$/ do |pos|
  @show = current_shows[pos.to_i - 1]
  within(:xpath, "(//ul[@id='of_shows']/li)[#{pos.to_i}]") do
    click_link "show-datetime"
  end
end

Then /^I should see (\d+) [Ss]hows$/ do |count|
  page.should have_xpath("//ul[@id='of_shows']/li", :count => count.to_i)
end

Given /^the (\d+)(?:st|nd|rd|th) [Ss]how has had tickets created$/ do |pos|
  current_shows[pos.to_i - 1].state = "built"
  show = current_shows[pos.to_i - 1]
  show.create_tickets
end

Given /^the (\d+)(?:st|nd|rd|th) [Ss]how has had tickets sold$/ do |pos|
  show = current_shows[pos.to_i - 1]
  show.tickets.first.sell_to(Factory(:person))
end

Given /^the (\d+)(?:st|nd|rd|th) [Ss]how is on sale$/ do |pos|
  current_shows[pos.to_i - 1].state = "on_sale"
  show = current_shows[pos.to_i - 1]
  tickets = show.tickets
  tickets.each { |ticket| ticket.state = "on_sale" }
end

Then /^I should not be able to delete the (\d+)(?:st|nd|rd|th) [Ss]how$/ do |pos|
  page.should have_no_xpath "(//tr[position()=#{pos.to_i}]/td[@class='actions']/a[@title='Delete'])"
end

Then /^I should not be able to edit the (\d+)(?:st|nd|rd|th) [Ss]how$/ do |pos|
  page.should have_no_xpath "(//tr[position()=#{pos.to_i}]/td[@class='actions']/a[@title='Edit'])"
end

Given /^a user@example.com named "([^"]*)" buys (\d+) tickets from the (\d+)(?:st|nd|rd|th) [Ss]how$/ do |name, wanted, pos|
  fname, lname = name.split(" ")
  customer = Factory(:person, :first_name => fname, :last_name => lname)

  show = current_shows[pos.to_i - 1]
  tickets = show.tickets
  tickets.reject { |t| t.state == "sold" }.first(wanted.to_i).each do |ticket|
    ticket.sell_to(customer)
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

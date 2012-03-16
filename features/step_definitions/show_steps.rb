When /^I delete the (\d+)(?:st|nd|rd|th) [Ss]how$/ do |pos|
  pending
end

When /^I view the (\d+)(?:st|nd|rd|th) [Ss]how in the list of shows$/ do |pos|
  @show = current_shows[pos.to_i - 1]
  within(:xpath, "(//ul[@id='of_shows']/li)[#{pos.to_i}]") do
    click_link "show-datetime"
  end
end

When /^I view the (\d+)(?:st|nd|rd|th) [Ss]how$/ do |pos|
  @show = current_shows[pos.to_i - 1]
  within("table tbody tr:nth-child(#{pos.to_i})") do
    click_link "show-datetime"
  end
end

Then /^I should see (\d+) [Ss]hows$/ do |count|
  page.should have_xpath("//ul[@id='of_shows']/li", :count => count.to_i)
end

Then /^I should see a list of played shows$/ do
  page.should have_xpath("//ul[@id='of_shows']/li")
end

Given /^the (\d+)(?:st|nd|rd|th) [Ss]how has had tickets created$/ do |pos|
  show = current_shows[pos.to_i - 1]
  show.build!
  show.create_tickets
end

Given /^the (\d+)(?:st|nd|rd|th) [Ss]how has had tickets sold$/ do |pos|
  show = current_shows[pos.to_i - 1]
  show.create_tickets if show.tickets.empty?
  show.tickets.first.sell_to(Factory(:person))
end

Given /^the (\d+)(?:st|nd|rd|th) [Ss]how is on sale$/ do |pos|
  show = current_shows[pos.to_i - 1]
  show.bulk_on_sale(:all)
  show.publish!
end

Then /^I should not be able to delete the (\d+)(?:st|nd|rd|th) [Ss]how$/ do |pos|
  page.should have_no_xpath "(//tr[position()=#{pos.to_i}]/td[@class='actions']/a[@title='Delete'])"
end

Then /^I should not be able to edit the (\d+)(?:st|nd|rd|th) [Ss]how$/ do |pos|
  page.should have_no_xpath "(//tr[position()=#{pos.to_i}]/td[@class='actions']/a[@title='Edit'])"
end

Given /^a user named "([^"]*)" buys (\d+) tickets from the (\d+)(?:st|nd|rd|th) [Ss]how$/ do |name, wanted, pos|
  fname, lname = name.split(" ")
  customer = Factory(:person, :first_name => fname, :last_name => lname)

  show = current_shows[pos.to_i - 1]
  tickets = show.tickets
  tickets.reject { |t| t.state == "sold" }.first(wanted.to_i).each do |ticket|
    ticket.sell_to(customer)
  end
end

Given /^a user named "([^"]*)" buys (\d+) tickets from the (\d+)(?:st|nd|rd|th) [Ss]how with instructions to "([^"]*)"$/ do |name, wanted, pos, special_instructions| 
  fname, lname = name.split(" ")
  customer = Factory(:person, :first_name => fname, :last_name => lname)

  show = current_shows[pos.to_i - 1]
  tickets = show.tickets
  
  order = Factory(:order, :person=>customer, :special_instructions=>special_instructions)
  
  tickets.reject { |t| t.state == "sold" }.first(wanted.to_i).each do |ticket|
    ticket.sell_to(customer)
    order << ticket
  end
end

When /^I search for the patron named "([^"]*)" email "([^"]*)"$/ do |name, email|
  fname, lname = name.split(" ")
  customer = Factory(:person, :first_name => fname, :last_name => lname, :email=>email, :organization_id => @current_user.current_organization.id)
  Person.stub(:search_index).and_return(Array.wrap(customer))
  When %{I fill in "Search" with "#{email}"}
end

When /^I confirm comp$/ do
  customer = Factory(:person)
  ticket = Factory(:ticket)
  And %{I press "Confirm"}
end

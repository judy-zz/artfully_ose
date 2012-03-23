Given /^I check the (\d+)(?:st|nd|rd|th) ticket for a comp$/ do |pos|
  within(:xpath, "(//div[@id='comps']/form/ul/li)[#{pos.to_i}]") do
    check("selected_tickets[]")
  end
end

When /^I select the first person$/ do
  find(:xpath, "(//div[@id='search-result-name'])").click
end

When /^I want to comp to "([^"]*)" email "([^"]*)"$/ do |name, email|
  fname, lname = name.split(" ")
  customer = Factory(:person, :first_name => fname, :last_name => lname, :email=>email, :organization_id => @current_user.current_organization.id)
  Person.stub(:search_index).and_return(Array.wrap(customer))
  step %{I fill in "search" with "#{email}"}
end
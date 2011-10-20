Given /^an athena person exists with an email of "([^"]*)"$/ do |email|
  Factory(:person, :email => email)
end

Given /^an athena person exists with an email of "([^"]*)" for my organization$/ do |email|
  Factory(:person, :email => email, :organization => @current_user.current_organization)
end

Given /^I search for the person "([^"]*)"$/ do |email|
end

Given /^there are (\d+) people tagged with "([^"]*)"$/ do |quantity, tag|
  @tag = tag
  @people = quantity.to_i.times.collect do
    person = Factory(:person, :organization => @current_user.current_organization)
    person.tag_list = Array.wrap(tag)
  end
end

Given /^I search for people tagged with "([^"]*)"$/ do |tag|
  visit people_path
  fill_in("search", :with => tag)
  click_button("Search")
end

Then /^I should see (\d+) people$/ do |count|
  page.should have_xpath("//ul[@class='people-list']/li", :count => count.to_i)
end

Given /^my organization has a dummy person record$/ do
  Factory(:dummy, :organization => @current_user.current_organization)
end


Given /^I view the people record for "([^"]*)"$/ do |email|
  @person ||= Factory(:person, :email => email, :organization => @current_user.current_organization)
  visit(person_path(@person))
end

Given /^there are no addresses for "([^"]*)"$/ do |email|
  @person ||= Factory(:person, :email => email, :organization => @current_user.current_organization)
end
Given /^an athena person exists with an email of "([^"]*)"$/ do |email|
  Factory(:person, :email => email)
end

Given /^a person exists with an email of "([^"]*)" for my organization$/ do |email|
  person = Factory(:person, :email => email, :organization => @current_user.current_organization)
  visit(person_path(person))
end

Given /^I search for the person "([^"]*)"$/ do |email|
end

Given /^"([^"]*)" is in the index$/ do |email|
  Person.stub(:search_index).and_return(Array.wrap(Person.where(:email => email)))
end

Then /^I enter a donation of "([^"]*)" on "([^"]*)"$/ do |amount, date|
  fill_in("Dollar Value", :with => amount)
  fill_in("Date and Time", :with => date)
  click_button("Save")
end

Then /^I search for contributions between "([^"]*)" and "([^"]*)"$/ do |from, to|
  fill_in("From", :with => from)
  fill_in("To", :with => to)
  click_button("Search")
end

Then /^I should see the contribution of "([^"]*)" from "([^"]*)" made on "([^"]*)"$/ do |amount, name, date|
  find('tr', text: name).should have_content(amount)
end

Given /^there are (\d+) people tagged with "([^"]*)"$/ do |quantity, tag|
  @tag = tag
  @people = quantity.to_i.times.collect do
    person = Factory(:person, :organization => @current_user.current_organization)
    person.tag_list = Array.wrap(tag)
    person
  end
end

Given /^I search for people tagged with "([^"]*)"$/ do |tag|
  Person.stub(:search_index).and_return(@people)
  visit people_path
  fill_in("search", :with => tag)
  click_button("Search")
end

Then /^I should see (\d+) people$/ do |count|
  page.should have_xpath("//table[@class='table people-list']/tbody/tr", :count => count.to_i)
end

Given /^I am looking at "([^" ]*) ([^" ]*)"$/ do |first_name, last_name|
  @person ||= Factory(:person, :first_name => first_name, :last_name => last_name, :organization => @current_user.current_organization)
  visit(person_path(@person))
end

Given /^I view the people record for "([^"]*)"$/ do |email|
  @person ||= Factory(:person, :email => email, :organization => @current_user.current_organization)
  visit(person_path(@person))
end

Given /^there are no addresses for "([^"]*)"$/ do |email|
  @person ||= Factory(:person, :email => email, :organization => @current_user.current_organization)
end
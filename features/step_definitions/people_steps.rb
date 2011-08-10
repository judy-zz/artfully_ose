Given /^an athena person exists with an email of "([^"]*)"$/ do |email|
  Factory(:athena_person_with_id, :email => email)
end

Given /^an athena person exists with an email of "([^"]*)" for my organization$/ do |email|
  Factory(:athena_person_with_id, :email => email, :organization => @current_user.current_organization)
end

Given /^I search for the person "([^"]*)"$/ do |email|
  FakeWeb.register_uri(:get, "http://localhost/people/people.json?_limit=10&_q=organizationId%3A1", [])
end

Given /^there are (\d+) people tagged with "([^"]*)"$/ do |quantity, tag|
  @people = quantity.to_i.times.collect do
    Factory(:athena_person_with_id, :tags => [ tag ])
  end
  body = @people.collect(&:encode).join(",")
  FakeWeb.register_uri(:get, "http://localhost/athena/people.json?_limit=10&_q=donor+AND+organizationId%3A#{@current_user.current_organization.id}", :body => "[#{body}]")
end

Given /^I search for people tagged with "([^"]*)"$/ do |tag|
  FakeWeb.register_uri(:get, "http://localhost/athena/people.json?_limit=10&_q=organizationId%3A#{@current_user.current_organization.id}", :body => "[]")
  visit people_path
  fill_in("search", :with => tag)
  click_button("Search")
end

Then /^I should see (\d+) people$/ do |count|
  page.should have_xpath("//ul[@class='people-list']/li", :count => count.to_i)
end

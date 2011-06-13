Given /^an athena person exists with an email of "([^"]*)"$/ do |email|
  Factory(:athena_person_with_id, :email => email)
end

Given /^an athena person exists with an email of "([^"]*)" for my organization$/ do |email|
  Factory(:athena_person_with_id, :email => email, :organization => @current_user.current_organization)
end

Given /^I search for the person "([^"]*)"$/ do |email|
  FakeWeb.register_uri(:get, "http://localhost/people/people.json?_limit=10&_q=organizationId%3A1", [])
end

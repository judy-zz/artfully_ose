Given /^"([^"]*)" is part of an organization$/ do |email|
  user = User.find_by_email(email)
  user.organizations << Factory(:organization)
  user.save
end

Given /^I am part of an organization$/ do
  @current_user.organizations << Factory(:organization)
end

Given /^I am part of an organization "([^"]*)"$/ do |name|
  @current_user.organizations << Organization.new(:name => name)
end

Given /^I create a new organization called "([^"]*)"$/ do |name|
  @current_user.organizations << Organization.new(:name => name)
end

Then /^I should be a part of the organization "([^"]*)"$/ do |name|
  @current_user.reload
  @current_user.organizations.should include Organization.find_by_name(name)
end
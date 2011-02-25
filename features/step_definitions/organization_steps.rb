Given /^"([^"]*)" is part of an organization$/ do |email|
  user = User.find_by_email(email)
  user.organizations << Factory(:organization)
  user.save
end

Given /^I am part of an organization$/ do
  @current_user.organizations << Factory(:organization)
end

Given /^I am part of an organization with access to the ticketing kit$/ do
  @current_user.organizations << Factory(:organization_with_ticketing)
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

Given /^"([^"]*)" is part of "([^"]*)"$/ do |email, organization|
  user = User.find_by_email(email)
  organization = Organization.find_by_name(organization)
  organization.users << user
end

When /^I click the link to remove "([^"]*)"$/ do |email|
  within(:xpath, "//ul/li[contains(.,'#{email}')]") do
    click_link "Remove from organization"
  end
end

Then /^"([^"]*)" should be a part of "([^"]*)"$/ do |email, organization|
  user = User.find_by_email(email)
  organization = Organization.find_by_name(organization)
  organization.users.should include user
end

Then /^"([^"]*)" should not be a part of "([^"]*)"$/ do |email, organization|
  user = User.find_by_email(email)
  organization = Organization.find_by_name(organization)
  organization.users.should_not include user
end

#$x("//ul/li[contains(.,'micah.frost@fracturedatlas.org')]");
Given /^"([^"]*)" is part of an organization$/ do |email|
  user = User.find_by_email(email)
  user.organizations << Factory(:organization)
  user.save
end

Given /^I am part of an organization$/ do
  @organization = Factory(:organization)
  @current_user.organizations << @organization
end

Given /^the organization that owns "([^"]*)" has a donation kit$/ do |name|
  organization = Event.find_by_name(name).organization
  Factory(:regular_donation_kit, :state => :activated, :organization => organization)
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
    click_link "Remove"
  end
end

Then /^"([^"]*)" should be a part of "([^"]*)"$/ do |email, organization|
  user = User.find_by_email(email)
  organization = Organization.find_by_name(organization)
  Membership.find_by_user_id_and_organization_id(user.id, organization.id).should be_persisted
end

Then /^"([^"]*)" should not be a part of "([^"]*)"$/ do |email, organization|
  user = User.find_by_email(email)
  organization = Organization.find_by_name(organization)
  Membership.find_by_user_id_and_organization_id(user.id, organization.id).should be_nil
end

Given /^my organization is connected to a Fractured Atlas membership$/ do
  org = @current_user.current_organization
  org.update_attribute(:fa_member_id, 1)
end

Given /^my organization has a website$/ do
  org = @current_user.current_organization
  org.update_attribute(:website,"http://test.com")
end

Then /^I my organization should have a Fractured Atlas membership$/ do
  @current_user.current_organization.should_not be_nil
end

Given /^my organization has tax information$/ do
  @current_user.current_organization.update_attributes({:ein => "111-1234", :legal_organization_name => "Some Organization"})
end

Given /^there is no organization with a name of "([^"]*)"$/ do |name|
  Organization.find_by_name(name).should be_blank
end

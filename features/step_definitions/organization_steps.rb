Given /^"([^"]*)" is part of an organization$/ do |email|
  user = User.find_by_email(email)
  user.organization = Factory(:organization)
  user.save
end

Then /^I should be a part of the organization "([^"]*)"$/ do |name|
  @current_user.reload
  @current_user.organization.should eq Organization.find_by_name(name)
end


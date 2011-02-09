Given /^"([^"]*)" is part of an organization$/ do |email|
  user = User.find_by_email(email)
  user.organizations << Factory(:organization)
  user.save
end

Then /^I should be a part of the organization "([^"]*)"$/ do |name|
  @current_user.reload
  @current_user.organizations.should include Organization.find_by_name(name)
end


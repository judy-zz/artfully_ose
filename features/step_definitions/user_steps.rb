Given /^I am logged in$/ do
  @current_user ||= Factory(:user)
  visit new_user_session_path
  fill_in("Email", :with => @current_user.email)
  fill_in("Password", :with => @current_user.password)
  click_button("Sign In")
end

And /^I sign in$/ do
  click_button("Sign In")
end

Given /^I am logged in as a user with email "([^"]*)"$/ do |email|
  @current_user = Factory(:user, :email => email)
  visit new_user_session_path
  fill_in("Email", :with => @current_user.email)
  fill_in("Password", :with => @current_user.password)
  click_button("Sign In")
end

When /^I delete the (\d+)(?:st|nd|rd|th) user$/ do |pos|
  visit users_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following users:$/ do |expected_users_table|
  expected_users_table.diff!(tableish('table tr', 'td,th'))
end

Then /^a reset password email was sent to "([^"]*)"$/ do |email|
  ActionMailer::Base.deliveries.should_not be_empty
  ActionMailer::Base.deliveries.first.subject eq "Reset password instructions"
  ActionMailer::Base.deliveries.first.to.should include email
end

Then /^an invite should have been sent to "([^"]*)"$/ do |email|
  User.find_by_email(email).invitation_token.should_not be_empty
end

Given /^I am logged in(?: as a "([^"]*)")?$/ do |role|
  role ||= "patron"
  @user = Factory(role)
  visit new_user_session_path
  fill_in("Email", :with => @user.email)
  fill_in("Password", :with => @user.password)
  click_button("Sign in")
end

Given /^the following users:$/ do |users|
  User.create!(users.hashes)
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

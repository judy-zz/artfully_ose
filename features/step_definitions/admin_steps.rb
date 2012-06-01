Given /^I am logged in as an admin$/ do
  Factory(:admin_stats)
  @current_admin = Factory(:admin)
  visit new_admin_session_path
  fill_in("Email", :with => @current_admin.email)
  fill_in("Password", :with => @current_admin.password)
  click_button("Sign in")
end

And /^I search for "([^"]*)"$/ do |email|
  fill_in("query", :with => email)
end

When /^I edit the bank account$/ do
  within("#bank-account") do
    step %{I follow "Edit"}
  end
end

When /^I add a bank account$/ do
  within("#bank-account") do
    step %{I follow "Add"}
  end
end

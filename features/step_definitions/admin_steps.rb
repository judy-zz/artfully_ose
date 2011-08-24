Given /^I am logged in as an admin$/ do
  @current_admin = Factory(:admin)
  visit new_admin_session_path
  fill_in("Email", :with => @current_admin.email)
  fill_in("Password", :with => @current_admin.password)
  click_button("Sign in")
end

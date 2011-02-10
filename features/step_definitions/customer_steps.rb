When /^I fill in valid customer details$/ do
  customer = Factory(:customer_with_id)
  When %{I fill in "First Name" with "#{customer.first_name}"}
  When %{I fill in "Last Name" with "#{customer.last_name}"}
  When %{I fill in "Phone" with "#{customer.phone}"}
  When %{I fill in "Email" with "#{customer.email}"}
end

Given /^I have a customer record$/ do
  @current_user.customer = Factory(:customer_with_id)
end

Given /^I have found the user "([^"]*)" to suspend$/ do |email|
  step %{I am on the admin users page}
  step %{a user exists with an email of "user@example.com"}
  step %{I follow "Users"}
  step %{I fill in "query" with "#{email}"}
  step %{I press "Search"}
  step %{I follow "#{email}"}
end


Then /^I should see "([^"]*)" in the search results$/ do |email|
  within("#users") do
    step %{I should see "#{email}"}
  end
end

Then /^I should not see "([^"]*)" in the search results$/ do |email|
  within("#users") do
    step %{I should not see "#{email}"}
  end
end


Given /^there is no user with an email of "([^"]*)"$/ do |email|
  User.find_by_email(email).should be_blank
end

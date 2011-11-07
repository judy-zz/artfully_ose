Given /^I have found the user "([^"]*)" to suspend$/ do |email|
  Given %{I am on the admin root page}
  And   %{a user exists with an email of "user@example.com"}
  And   %{I follow "Users"}
  And   %{I fill in "Query" with "#{email}"}
  And   %{I press "Search"}
  And   %{I follow "#{email}"}
end


Then /^I should see "([^"]*)" in the search results$/ do |email|
  within("#users") do
    Then %{I should see "#{email}"}
  end
end

Then /^I should not see "([^"]*)" in the search results$/ do |email|
  within("#users") do
    Then %{I should not see "#{email}"}
  end
end


Given /^there is no user with an email of "([^"]*)"$/ do |email|
  User.find_by_email(email).should be_blank
end

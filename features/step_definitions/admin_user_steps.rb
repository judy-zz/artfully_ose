Given /^I have found the user "([^"]*)" to suspend$/ do |email|
  Given %{I am on the admin root page}
  And   %{a user exists with an email of "user@example.com"}
  And   %{I follow "Users"}
  And   %{I fill in "Email" with "#{email}"}
  And   %{I press "Search"}
end

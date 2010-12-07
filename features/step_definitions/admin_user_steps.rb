Given /^I have found the user "([^"]*)" to suspend$/ do |email|
  Given %{I am on the admin root page}
  And   %{a patron exists with an email of "patron@example.com"}
  And   %{I follow "Users"}
  And   %{I fill in "Email" with "#{email}"}
  And   %{I press "Search"}
end

Given /^I peep statements$/ do
  # Given %{I am on the root page}
  # And %{I follow "Statements"}
end

Then /^I should see a statement$/ do
  page.should have_content("Statement Report:")
end

Given /^I do an advanced search for people tagged with "([^"]*)"$/ do |tag|
  visit new_search_path
  fill_in("search_tagging", :with => tag)
  click_button("Search")
end

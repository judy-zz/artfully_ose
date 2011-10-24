Then /^the person record for "([^"]*)" should have the tag "([^"]*)"$/ do |email, tag|
  person = Person.find_by_email(email)
  person.tag_list.should include(tag)
end

Given /^"([^"]*)" has a phone number$/ do |email|
  person = Person.find_by_email(email)
  person.phones << Factory(:phone)
  visit(person_path(person))
end

Then /^the person record for "([^"]*)" should have "([^"]*)" as a "([^"]*)" number$/ do |email, number, kind|
  person = Person.find_by_email(email)
  person.phones.where(:number => number, :kind => kind).count == 1
end

Then /^the person record for "([^"]*)" should not have "([^"]*)" as a "([^"]*)" number$/ do |email, number, kind|
  person = Person.find_by_email(email)
  person.phones.where(:number => number, :kind => kind).count == 0
end

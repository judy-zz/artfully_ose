Given /^an athena person exists with an email of "([^"]*)"$/ do |email|
  Factory(:athena_person_with_id, :email => email)
end

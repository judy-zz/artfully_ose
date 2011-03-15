Given /^an athena person exists with an email of "([^"]*)"$/ do |email|
  Factory(:athena_person_with_id, :email => email)
end

Given /^an athena person exists with an email of "([^"]*)" for my organization$/ do |email|
  Factory(:athena_person_with_id, :email => email, :organization => @current_user.current_organization)
end

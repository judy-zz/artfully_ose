Given /^"([^"]*)" is part of an organization$/ do |email|
  user = User.find_by_email(email)
  user.organization = Factory(:organization)
  user.save
end

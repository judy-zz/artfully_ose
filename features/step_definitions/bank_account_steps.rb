Then /^the organization "([^"]*)" should have a bank account$/ do |name|
  Organization.find_by_name(name).bank_account.should_not be_nil
end

Then /^the organization "([^"]*)" should not have a bank account$/ do |name|
  Organization.find_by_name(name).bank_account.should be_nil
end

Given /^the organization "([^"]*)" has a bank account$/ do |name|
  Organization.find_by_name(name).bank_account = Factory(:bank_account)
end
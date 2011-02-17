Given /^there is a pending donation kit application for "([^"]*)"$/ do |name|
  organization = Factory(:organization, :name => name)
  organization.kits << DonationKit.new
end

Then /^the donation kit for "([^"]*)" should be activated$/ do |name|
  organization = Organization.find_by_name(name)
  organization.kits.first.should be_activated
end

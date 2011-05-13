Given /^there is a pending regular donation kit application for "([^"]*)"$/ do |name|
  organization = Factory(:organization, :name => name)
  organization.users << Factory(:user)
  organization.update_attributes({:ein => "111-1234", :legal_organization_name => "Some Organization"})
  organization.kits << RegularDonationKit.new
end

Then /^the regular donation kit for "([^"]*)" should be activated$/ do |name|
  organization = Organization.find_by_name(name)
  organization.kits.first.should be_activated
end

Given /^there is a pending sponsored donation kit application for "([^"]*)"$/ do |name|
  organization = Factory(:organization, :name => name)
  organization.users << Factory(:user)
  organization.update_attribute(:fa_member_id, 1)
  organization.update_attribute(:website, "http://test.com")
  organization.kits << SponsoredDonationKit.new
end

Then /^the regular sponsored kit for "([^"]*)" should be activated$/ do |name|
  organization = Organization.find_by_name(name)
  organization.kits.first.should be_activated
end

Given /^there is a pending ticketing kit application for "([^"]*)"$/ do |name|
  organization = Factory(:organization, :name => name)
  user = Factory(:user)
  user.customer = Factory(:customer_with_credit_cards)
  organization.users << user
  organization.kits << TicketingKit.new
end

Then /^the ticketing kit for "([^"]*)" should be activated$/ do |name|
  organization = Organization.find_by_name(name)
  organization.kits.where(:type => "TicketingKit").first.should be_activated
end

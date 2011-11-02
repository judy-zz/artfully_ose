When /^I fill out the address form$/ do
  address = Factory.build(:address)
  fill_in("Address", :with => address.address1)
  fill_in("Secondary", :with => address.address2)
  fill_in("City", :with => address.city)
  select(address.state, :from => "State")
  fill_in("Zip", :with => address.zip)
  fill_in("Country", :with => address.country)
end

Given /^there is an address for the people record for "([^"]*)"$/ do |email|
  @person ||= Factory(:person, :email => email, :organization => @current_user.current_organization)
  Factory(:address, :person => @person)
end
Given /^I have a reseller profile$/ do
  @reseller_profile = @organization.reseller_profile

  if !@reseller_profile
    @reseller_profile = Factory(:reseller_profile, :organization => @organization)
    @organization.reload
  end
end

Given /^I have a reseller event "([^"]*)"$/ do |event_name|
  @reseller_event = Factory(:reseller_event, :reseller_profile => @reseller_profile, :name => event_name)
end

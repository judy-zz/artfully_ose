Given /^there are (\d+) settlements for "([^"]*)"$/ do |number, organization_name|
  organization = Organization.find_by_name(organization_name)
  settlements = number.to_i.times.collect { Factory(:settlement_with_id, :organization_id => organization.id) }
end

Then /^I should see (\d+) settlements$/ do |count|
  page.should have_xpath("//div[@id='settlements']/table/tbody/tr", :count => count.to_i)
end

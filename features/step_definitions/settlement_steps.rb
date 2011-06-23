Given /^there are (\d+) settlements for "([^"]*)"$/ do |number, organization_name|
  organization = Organization.find_by_name(organization_name)
  settlements = number.to_i.times.collect { Factory(:settlement, :organization_id => organization.id) }
  body = settlements.collect(&:encode).join(",")
  FakeWeb.register_uri(:get, "http://localhost/orders/settlements.json?organizationId=#{organization.id}", :body => "[#{body}]")
end

Then /^I should see (\d+) settlements$/ do |count|
  page.should have_xpath("//div[@id='settlements']/table/tbody/tr", :count => count.to_i)
end

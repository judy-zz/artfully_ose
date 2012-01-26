Given /^there are (\d+) contacts$/ do |count|
  @people = (0 ... count.to_i).map { Factory(:person, :organization => @organization) }
end

Given /^there are (\d+) donations$/ do |count|
  @donations = (0 ... count.to_i).map { Factory(:donation, :organization_id => @organization.id) }
end

Then /^I should receive a file "([^"]*)" named for today$/ do |filename|
  filename = filename % [ Time.now.strftime("%m-%d-%y") ]
  page.response_headers['Content-Disposition'].should include("filename=\"#{filename}\"")
end

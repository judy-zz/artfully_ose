Given /^there are (\d+) contacts$/ do |count|
  @people = (0 ... count.to_i).map { Factory(:athena_person_with_id, :organization => @organization) }
  encoded_people = @people.map { |person| person.encode }
  person_list = "[" + encoded_people.join(",") + "]"
  person_url = "http://localhost/athena/people.json?organizationId=#{@organization.id}"
  FakeWeb.register_uri :get, person_url, :body => person_list
end

Given /^there are (\d+) donations$/ do |count|
  @donations = (0 ... count.to_i).map { Factory(:athena_donation, :organization_id => @organization.id) }
  body = "[" + @donations.map(&:order).map(&:encode).join(",") + "]"
  FakeWeb.register_uri(:get, "http://localhost/athena/orders.json?_limit=100&_start=0&organizationId=#{@organization.id}", :body => body)
  body = "[" + @donations.map(&:encode).join(",") + "]"
  FakeWeb.register_uri(:get, %r|http://localhost/athena/items.json.*|, :body => body)
end

Then /^I should receive a file "([^"]*)" named for today$/ do |filename|
  filename = filename % [ Time.now.strftime("%m-%d-%y") ]
  page.response_headers['Content-Disposition'].should include("filename=\"#{filename}\"")
end

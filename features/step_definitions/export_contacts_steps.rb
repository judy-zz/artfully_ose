Given /^there are (\d+) contacts$/ do |count|
  @people = (0 ... count.to_i).map { Factory(:athena_person_with_id) }
  encoded_people = @people.map { |person| person.encode }
  person_list = "[" + encoded_people.join(",") + "]"
  person_url = "http://localhost/athena/people.json?organizationId=#{@organization.id}"
  FakeWeb.register_uri :get, person_url, :body => person_list
end

Then /^I should receive a file "([^"]*)" named for today$/ do |filename|
  filename = filename % [ Time.now.strftime("%m-%d-%y") ]
  page.response_headers['Content-Disposition'].should include("filename=\"#{filename}\"")
end

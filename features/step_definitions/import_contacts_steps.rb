When /^I upload a new import file "([^"]*)"$/ do |filename|
  path = Rails.root.join("features", "support", filename)
  visit new_import_path(:bucket => "test", :key => path, :etag => "12345")
  @import = Import.last
end

Then /^the number of imports should change to (\d+)$/ do |arg1|
  Import.count.should == arg1.to_i
end

When /^the import is performed$/ do
  FakeWeb.register_uri(:get, "http://localhost/athena/people.json?_limit=500&_start=0&importId=#{@import.id}", :body => "[]")
  FakeWeb.register_uri(:get, %r{http://localhost/athena/people.json\?email=.*&organizationId=.*}, :body => "[]")
  @import.reload.perform
end

Then /^there should be no import errors$/ do
  @import.import_errors.should be_empty
end

Then /^the import's status should be (.*)$/ do |status|
  @import.reload.status.should == status
end

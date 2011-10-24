Given /^there are (\d+) settlements for "([^"]*)"$/ do |number, organization_name|
  organization = Organization.find_by_name(organization_name)
  settlements = number.to_i.times.collect { Factory(:settlement, :organization_id => organization.id) }
end

Then /^I should see (\d+) settlements$/ do |count|
  page.should have_xpath("//div[@id='settlements']/table/tbody/tr", :count => count.to_i)
end

Given /^there is a settleable show for "([^"]*)"$/ do |event|
  @settleable_show = Factory(:settleable_show, :event => Factory(:event, :name => event))
  Show.stub(:in_range).and_return(Array.wrap(@settleable_show))
end

When /^the settlement job runs$/ do
  FakeWeb.register_uri(:get, %r|https://demo.firstach.com/https/TransRequest\.asp?.*|, :body => "011234567")
  Job::Settlement.run
end

Then /^there should be a settlement for the show$/ do
  @settleable_show.settlement.should_not be_nil
end

Then /^the shows sales should be settled$/ do
  @settleable_show.reload
  @settleable_show.items.all?(&:settled?).should be_true
end

Given /^there are settleable donations for the organization "([^"]*)"$/ do |name|
  organization = Factory(:organization_with_bank_account, :name => name)
  donations = 3.times.collect { Factory(:donation, :organization => organization) }
  @order = Factory(:order, :organization => organization, :items => donations.collect{ |donation| Item.for(donation)})
  Order.stub(:in_range).and_return(Array.wrap(@order))
end

Then /^the donations should be settled$/ do
  @order.reload
  @order.items.all?(&:settled?).should be_true
end

When /^I save the list segment$/ do
  segment = Segment.new(:name => "New Segment", :terms => @tag)
  segment.organization = @current_user.current_organization
  click_button("Create")
end

Given /^there is a list segment called "([^"]*)"$/ do |arg1|
  search = Search.new(:tagging => "dummy")
  search.organization = @current_user.current_organization
  search.save!
  segment = Segment.new(:name => arg1, :search_id => search.id)
  segment.organization = @current_user.current_organization
  segment.save!
end

Given /^I decide I don't want it any more so I click Delete$/ do
  click_link("Delete")
end
When /^I save the list segment$/ do
  segment = Segment.new(:name => "New Segment", :terms => @tag)
  segment.organization = @current_user.current_organization
  click_button("Create")
end

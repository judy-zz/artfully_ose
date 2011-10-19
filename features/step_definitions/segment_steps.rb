When /^I save the list segment$/ do
  segment = Segment.new(:name => "New Segment", :terms => @tag)
  segment.organization = @current_user.current_organization
  segment.people = @people
  segment.id = 1
  click_button("Create")
end

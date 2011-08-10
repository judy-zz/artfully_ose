When /^I save the list segment$/ do
  list_segment = ListSegment.new(:name => "New Segment")
  list_segment.organization = @current_user.current_organization
  list_segment.people = @people
  list_segment.id = 1
  FakeWeb.register_uri(:post, "http://localhost/athena/list_segments.json", :body => list_segment.encode)
  FakeWeb.register_uri(:get, "http://localhost/athena/list_segments/1.json", :body => list_segment.encode)
  click_button("Create")
end

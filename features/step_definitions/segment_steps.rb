When /^I save the list segment$/ do
  segment = Segment.new(:name => "New Segment", :terms => @tag)
  segment.organization = @current_user.current_organization
  segment.people = @people
  segment.id = 1
  FakeWeb.register_uri(:post, "http://localhost/athena/segments.json", :body => segment.encode)
  FakeWeb.register_uri(:get, "http://localhost/athena/segments/1.json", :body => segment.encode)
  click_button("Create")
end

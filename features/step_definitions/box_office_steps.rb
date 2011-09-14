When /^I find a customer record for the order$/ do
  fill_in("terms", :with => "Something")
  body = "[#{Factory(:athena_person_with_id).encode}]"
  FakeWeb.register_uri(:get, %r|http://localhost/athena/people\.json\?.*_q=Something.*|, :body => body)
  click_button("Search")
  click_button("Select")
end

Given /^the credentials I'll enter are valid$/ do
  id = 1
  body = { :session => { :user => { :member_id => 1 } } }.to_xml
  FakeWeb.register_uri(:get, "http://api.fracturedatlas.org/sessions/#{id}.xml", :body => body)
  FakeWeb.register_uri(:post, "http://api.fracturedatlas.org/sessions.xml", :location => "http://api.fracturedatlas.org/sessions/#{id}.xml")
end

Given /^the credentials I'll enter are not valid$/ do
  FakeWeb.register_uri(:post, "http://api.fracturedatlas.org/sessions.xml", :status => 403)
end

Factory.define :person do |p|
  p.email           { Faker::Internet.email}
  p.first_name      { Faker::Name.first_name }
  p.last_name       { Faker::Name.last_name }
  p.association     :organization
end

Factory.define(:purchase_action) do |a|
  a.person { Factory(:person) }
  # a.subject { Factory(:order_with_id) }
  a.occurred_at { DateTime.now }
end

Factory.define(:donation_action) do |a|
  a.person { Factory(:person) }
  a.subject { Factory(:donation) }
  a.occurred_at { DateTime.now }
end

Factory.define(:segment, :default_strategy => :build) do |ls|
  ls.name "Some List Segment"
  ls.organization { Factory(:organization) }
end

Factory.define(:dummy, :parent => :person) do |p|
  p.dummy true
end

Factory.sequence :address_id do |n|
  n.to_s
end

Factory.define(:address, :default_strategy => :build) do |a|
  a.id              { Factory.next(:address_id) }
  a.address1        { Faker::Address.street_address }
  a.address2        { Faker::Address.secondary_address }
  a.city            { Faker::Address.city }
  a.state           { Faker::Address.us_state }
  a.zip             { Faker::Address.zip_code }
  a.country         "United States"

  a.after_build do |address|
    FakeWeb.register_uri(:post, %r|http://localhost/athena/addresses\.json.*|, :body => address.encode)
    FakeWeb.register_uri(:put, "http://localhost/athena/addresses/#{address.id}.json", :body => address.encode)
    FakeWeb.register_uri(:get, "http://localhost/athena/addresses.json?personId=#{address.person_id}", :body => "[#{address.encode}]")
  end

end
Factory.sequence :person_id do |n|
  n
end

Factory.define :athena_person, :default_strategy => :build do |p|
  p.email           { Faker::Internet.email}
  p.first_name      { Faker::Name.first_name }
  p.last_name       { Faker::Name.last_name }
  p.organization    { Factory(:organization) }
end

Factory.define :athena_person_with_id, :parent => :athena_person do |p|
  p.id { Factory.next :person_id }
  p.after_build do |person|
    FakeWeb.register_uri(:any, "http://localhost/athena/people/#{person.id}.json", :body => person.encode)
    FakeWeb.register_uri(:get, "http://localhost/athena/people.json?email=eq#{CGI::escape(person.email)}&organizationId=eq#{person.organization_id}", :body => "[#{person.encode}]")
  end
end

Factory.define :athena_relationship, :default_strategy => :build do |r|
  r.relationship_type "Father"
  r.inverse_type "Son"
  r.left_side_id { Factory(:athena_person_with_id).id }
  r.right_side_id { Factory(:athena_person_with_id).id }
end

Factory.define :athena_purchase_action, :default_strategy => :build do |a|
  a.person { Factory(:athena_person_with_id) }
  a.subject { Factory(:athena_order_with_id) }
  a.occurred_at { DateTime.now }
end

Factory.define :athena_donation_action, :default_strategy => :build do |a|
  a.person { Factory(:athena_person_with_id) }
  a.subject { Factory(:donation) }
  a.occurred_at { DateTime.now }
end

Factory.define(:segment, :default_strategy => :build) do |ls|
  ls.name "Some List Segment"
  ls.organization { Factory(:organization) }
end
Factory.sequence :person_id do |n|
  n
end

Factory.define :person, :default_strategy => :build do |p|
  p.email           { Faker::Internet.email}
  p.first_name      { Faker::Name.first_name }
  p.last_name       { Faker::Name.last_name }
  p.organization    { Factory(:organization) }
end

Factory.define :person_with_id, :parent => :person do |p|
  p.id { Factory.next :person_id }
end

Factory.define :purchase_action, :default_strategy => :build do |a|
  a.person { Factory(:person_with_id) }
  # a.subject { Factory(:order_with_id) }
  a.occurred_at { DateTime.now }
end

Factory.define :donation_action, :default_strategy => :build do |a|
  a.person { Factory(:person_with_id) }
  a.subject { Factory(:donation) }
  a.occurred_at { DateTime.now }
end

Factory.define(:segment, :default_strategy => :build) do |ls|
  ls.name "Some List Segment"
  ls.organization { Factory(:organization) }
end

Factory.define(:dummy, :parent => :person_with_id) do |p|
  p.dummy true
end
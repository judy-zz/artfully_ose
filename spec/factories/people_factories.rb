Factory.define :person do |p|
  p.email           { Faker::Internet.email}
  p.first_name      { Faker::Name.first_name }
  p.last_name       { Faker::Name.last_name }
  p.association     :organization
end

Factory.define :purchase_action, :default_strategy => :build do |a|
  a.person { Factory(:person) }
  # a.subject { Factory(:order_with_id) }
  a.occurred_at { DateTime.now }
end

Factory.define :donation_action, :default_strategy => :build do |a|
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
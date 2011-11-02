Factory.define(:purchase_action) do |a|
  a.association :person
  a.occurred_at { DateTime.now }
end

Factory.define(:donation_action) do |a|
  a.association :person
  a.subject { Factory(:donation) }
  a.occurred_at { DateTime.now }
end
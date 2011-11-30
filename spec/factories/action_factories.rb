Factory.define(:purchase_action) do |a|
  a.association :person
  a.occurred_at { DateTime.now }
end

Factory.define(:give_action) do |a|
  a.association :person
  a.subject { Factory(:donation) }
  a.occurred_at { DateTime.now }
end
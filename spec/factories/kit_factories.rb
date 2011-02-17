Factory.define :ticketing_kit do |t|
  t.association :organization
end

Factory.define :donation_kit do |t|
  t.association :organization
end
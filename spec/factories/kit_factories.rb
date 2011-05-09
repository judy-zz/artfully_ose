Factory.define :ticketing_kit do |t|
  t.association :organization
end

Factory.define :regular_donation_kit do |t|
  t.association :organization
end

Factory.define :sponsored_donation_kit do |t|
  t.association :organization
end
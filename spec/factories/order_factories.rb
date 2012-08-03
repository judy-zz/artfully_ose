Factory.define(:order) do |o|
  o.transaction_id "j59qrb"
  o.price 50
  o.association :person
  o.association :organization
end

Factory.define :reseller_order, :class => Reseller::Order do |o|
  o.person { Factory :person }
  o.organization { Factory :organization_with_reselling }
end

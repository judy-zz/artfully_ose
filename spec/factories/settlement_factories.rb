Factory.define(:settlement) do |s|
  s.transaction_id "1231234"
  
  s.association :show
  s.association :organization
  s.net         100000
  s.success     true
end

Factory.define :failed_settlement, :parent => :settlement do |s|
  s.success     false
end

Factory.define(:reseller_settlement, :class => ResellerSettlement) do |f|
  f.transaction_id "1231234"

  f.association :show
  f.association :organization
  f.net         100000
  f.success     true
end

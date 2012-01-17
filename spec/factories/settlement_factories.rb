Factory.define(:settlement) do |s|
  s.transaction_id "1231234"
  
  s.association :show
  s.association :organization
  s.net         100000
end
Factory.define :donation do |d|
  d.amount 1000
  d.association :organization
end
Factory.define(:segment) do |ls|
  ls.name "Some List Segment"
  ls.association :organization
end
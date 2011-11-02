Factory.define(:segment, :default_strategy => :build) do |ls|
  ls.name "Some List Segment"
  ls.association :organization
end
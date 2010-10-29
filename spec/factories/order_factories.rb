Factory.define(:order) do |o|
  o.transaction { Factory(:transaction) }
end

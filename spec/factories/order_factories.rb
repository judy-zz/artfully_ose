Factory.define(:order) do |o|
  o.transaction { Factory(:transaction, :tickets => ["1","2"]) }
  o.tickets ["1","2"]
end

Factory.define(:order_without_transaction, :class => :order) do |o|
end

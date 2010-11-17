Factory.define(:order) do |o|
  o.lock { Factory(:lock, :tickets => ["1","2"]) }
  o.tickets ["1","2"]
end

Factory.define(:order_without_lock, :class => :order, :default_strategy => :build) do |o|
end

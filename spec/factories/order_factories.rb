Factory.define(:order) do |o|
end

Factory.define(:order_without_lock, :class => :order, :default_strategy => :build) do |o|
end

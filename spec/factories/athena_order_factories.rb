Factory.define :athena_order, :default_strategy => :build do |o|
  o.person { Factory(:athena_person) }
  o.organization { Factory(:organization) }
  o.customer { Factory(:customer_with_id) }
  o.price 50
end
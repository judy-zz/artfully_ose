Factory.sequence :id do |n|
  "#{n}"
end

Factory.define :payment, :class => AthenaPayment, :default_strategy => :build do |p|
  p.amount 100
  p.billing_address { Factory(:address) }
  p.credit_card { Factory(:credit_card) }
  p.customer { Factory(:customer) }
end

Factory.define :payment_with_id, :class => AthenaPayment, :default_strategy => :build do |p|
  p.id { Factory.next :id }
end

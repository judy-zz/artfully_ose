Factory.sequence :id do |n|
  "#{n}"
end

Factory.define :payment, :default_strategy => :build do |p|
  p.amount 100
  p.shipping_address { Factory(:address) }
  p.billing_address { Factory(:address) }
  p.credit_card { Factory(:credit_card) }
end

Factory.define :payment_with_id, :class => Payment, :default_strategy => :build do |p|
  p.id { Factory.next :id }
end

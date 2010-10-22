Factory.sequence :id do |n|
  "#{n}"
end

Factory.define :payment, :default_strategy => :build do |t|
end

Factory.define :payment_with_id, :class => Payment, :default_strategy => :build do |t|
  t.id { Factory.next :id }
end

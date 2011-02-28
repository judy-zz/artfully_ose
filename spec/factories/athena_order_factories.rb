Factory.sequence :athena_order_id do |n|
  n
end

Factory.define :athena_order, :default_strategy => :build do |o|
  o.person { Factory(:athena_person_with_id) }
  o.organization { Factory(:organization) }
  o.customer { Factory(:customer_with_id) }
  o.price 50

  o.after_build do |order|
    FakeWeb.register_uri(:post, "http://localhost/orders/orders/.json", :body => order.encode)
  end
end

Factory.define :athena_order_with_id, :parent => :athena_order do |o|
  o.id Factory.next :athena_order_id
end

Factory.define :athena_item, :default_strategy => :build do |i|
  i.order { Factory(:athena_order) }
  i.item_type "AthenaTicket"
  i.item_id { Factory(:ticket_with_id) }
  i.price 10
end
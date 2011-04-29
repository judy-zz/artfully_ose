Factory.sequence :athena_order_id do |n|
  n
end

Factory.sequence :athena_item_id do |n|
  n
end

Factory.define :athena_order, :default_strategy => :build do |o|
  o.person { Factory(:athena_person_with_id) }
  o.organization { Factory(:organization) }
  o.customer { Factory(:customer_with_id) }
  o.transaction_id "j59qrb"
  o.price 50
end

Factory.define :athena_order_with_id, :parent => :athena_order do |o|
  o.id Factory.next :athena_order_id
  o.after_build do |order|
    FakeWeb.register_uri(:post, "http://localhost/orders/orders.json", :body => order.encode)
    FakeWeb.register_uri(:any, "http://localhost/orders/orders/#{order.id}.json", :body => order.encode)
    FakeWeb.register_uri(:get, "http://localhost/orders/orders.json?parentId=#{order.id}", :body => "[]")
  end
end

Factory.define :athena_item, :default_strategy => :build do |i|
  i.order { Factory(:athena_order_with_id) }
  i.item_type "AthenaTicket"
  i.item_id { Factory(:sold_ticket_with_id).id }
  i.price 1000
end

Factory.define :athena_item_with_id, :parent => :athena_item do |i|
  i.id Factory.next :athena_item_id
  i.after_build do |item|
    FakeWeb.register_uri(:get, "http://localhost/orders/items/#{item.id}.json", :body => item.encode)
    FakeWeb.register_uri(:put, "http://localhost/orders/items/#{item.id}.json", :body => "")
  end
end
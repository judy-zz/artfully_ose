Factory.sequence :athena_order_id do |n|
  n
end

Factory.sequence :athena_item_id do |n|
  n
end

Factory.define :athena_order, :default_strategy => :build do |o|
  o.person { Factory(:person) }
  o.organization { Factory(:organization) }
  o.customer { Factory(:customer_with_id) }
  o.transaction_id "j59qrb"
  o.timestamp { DateTime.now }
  o.price 50
end

Factory.define :athena_order_with_id, :parent => :athena_order do |o|
  o.id Factory.next :athena_order_id
  o.after_build do |order|
    FakeWeb.register_uri(:post, "http://localhost/athena/orders.json", :body => order.encode)
    FakeWeb.register_uri(:any, "http://localhost/athena/orders/#{order.id}.json", :body => order.encode)
    FakeWeb.register_uri(:get, "http://localhost/athena/orders.json?parentId=#{order.id}", :body => "[]")
  end
end

Factory.define :athena_item, :default_strategy => :build do |i|
  i.order { Factory(:athena_order_with_id) }
  i.product { Factory(:sold_ticket_with_id) }
  i.price 1000
end

Factory.define :athena_item_with_id, :parent => :athena_item do |i|
  i.id { Factory.next :athena_item_id }
  i.after_build do |item|
    FakeWeb.register_uri(:get, "http://localhost/athena/items/#{item.id}.json", :body => item.encode)
    FakeWeb.register_uri(:put, "http://localhost/athena/items/#{item.id}.json", :body => "")
  end
end

Factory.define :fa_item, :parent => :athena_item do |i|

end

Factory.define :athena_item_for_comped_ticket, :default_strategy => :build, :class => AthenaItem do |i|
  i.id    { Factory.next(:athena_item_id)               }
  i.order { Factory(:athena_order_with_id)              }
  i.product  { Factory(:ticket_with_id, :state => :comped) }
  i.price 1000
  i.after_build do |item|
    FakeWeb.register_uri(:get, "http://localhost/athena/items/#{item.id}.json", :body => item.encode)
    FakeWeb.register_uri(:put, "http://localhost/athena/items/#{item.id}.json", :body => "")
  end
end

Factory.sequence(:settlement_id) do |n|
  n.to_s
end

Factory.define(:settlement, :default_strategy => :build) do |s|
  s.transaction_id "1231234"
end

Factory.define(:settlement_with_id, :parent => :settlement) do |s|
  s.id { Factory.next(:settlement_id) }
  s.after_build do |settlement|
    FakeWeb.register_uri(:get, "http://localhost/order/settlements/#{settlement.id}.json", :body => settlement.encode)
  end
end
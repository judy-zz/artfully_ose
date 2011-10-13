Factory.define(:order) do |o|
  o.transaction_id "j59qrb"
  o.price 50
  o.association :person
  o.association :organization
end

Factory.define(:item) do |i|
  i.product { Factory(:sold_ticket) }
  i.price 1000
  i.association :order
end

Factory.define :fa_item, :parent => :item do |i|
end

Factory.define(:comped_item, :parent => :item) do |i|
  i.product { Factory(:ticket, :state => :comped) }
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
Factory.define(:item) do |i|
  i.product { Factory(:sold_ticket) }
  i.price 1000
  i.association :order
end

Factory.define(:fa_item, :parent => :item) do |i|
  i.nongift_amount 400
end

Factory.define(:comped_item, :parent => :item) do |i|
  i.product { Factory(:ticket, :state => :comped) }
end
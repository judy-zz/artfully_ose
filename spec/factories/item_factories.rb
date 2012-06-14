Factory.define(:item) do |i|
  i.product { Factory.create(:sold_ticket) }
  
  #price is going to be assigned when product is called.  Setting it here will not work
  
  i.association :order
  i.reseller_net 100
end

Factory.define(:free_item, :parent => :item) do |i|
  i.price 0
end

Factory.define(:fa_item, :parent => :item) do |i|
  i.nongift_amount 400
end

Factory.define(:settled_item, :parent => :item) do |i|
  i.product { Factory(:ticket, :state => :sold) }
  i.state   "settled"
end

Factory.define(:comped_item, :parent => :item) do |i|
  i.product { Factory(:ticket, :state => :comped) }
  i.state   "comped"
end

Factory.define(:exchanged_item, :parent => :item) do |i|
  i.product { Factory(:ticket, :state => :on_sale) }
  i.state   "exchanged"
end

Factory.define(:exchangee_item, :parent => :item) do |i|
  i.product { Factory(:ticket, :state => :sold) }
  i.state   "exchangee"
end

Factory.define(:refunded_item, :parent => :item) do |i|
  i.product { Factory(:ticket, :state => :on_sale) }
  i.state   "refunded"
end

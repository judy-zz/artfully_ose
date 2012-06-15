Factory.define(:item) do |i|
  i.product { Factory.create(:sold_ticket) }
  
  #price is going to be assigned when product is called.  Setting it here will not work
  
  i.association :order
  i.reseller_net 100
end

Factory.define(:free_item, :parent => :item) do |i|
  i.product { Factory.create(:free_ticket) }
  i.association :order
end

Factory.define(:fa_item, :parent => :item) do |i|
  i.nongift_amount 400
end

#
# These stopped working since the move to Rails 3.1 and FactoryGirl 2.5
# Haven't hand time to run down why. It is because item.product gets run after item.state for some reason
# and the call to product resets the state.
#

Factory.define(:settled_item, :class => Item) do |i|
  i.product { Factory(:ticket, :state => :sold) }
  i.state   "settled"
end

Factory.define(:comped_item, :class => Item) do |i|
  i.product { Factory(:ticket, :state => :comped) }
  i.state   "comped"
end

Factory.define(:exchanged_item, :class => Item) do |i|
  i.product { Factory(:ticket, :state => :on_sale) }
  i.state   "exchanged"
end

Factory.define(:exchangee_item, :class => Item) do |i|
  i.product { Factory(:ticket, :state => :sold) }
  i.state   "exchangee"
end

Factory.define(:refunded_item, :class => Item) do |i|
  i.product { Factory(:ticket, :state => :on_sale) }
  i.state   "refunded"
end

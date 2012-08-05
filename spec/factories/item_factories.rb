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

Factory.define(:comped_item, :class => Item) do |i|
  i.product { Factory(:ticket, :state => :comped) }
  i.after_build do |i|
    i.state="comped"
  end
end

Factory.define(:exchanged_item, :class => Item) do |i|
  i.product { Factory(:ticket, :state => :on_sale) }
  i.after_build do |i|
    i.state="exchanged"
  end
end

Factory.define(:exchangee_item, :class => Item) do |i|
  i.product { Factory(:ticket, :state => :sold) }
  i.after_build do |i|
    i.state="exchangee"
  end
end

Factory.define(:refunded_item, :class => Item) do |i|
  i.product { Factory(:ticket, :state => :on_sale) }
  i.after_build do |i|
    i.state="refunded"
  end
end

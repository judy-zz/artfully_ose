Factory.define :purchasable_ticket do |pt|
  pt.ticket { Factory(:ticket) }
end
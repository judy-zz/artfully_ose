Factory.define :purchasable_ticket do |pt|
  pt.ticket { Factory(:ticket_with_id) }
end
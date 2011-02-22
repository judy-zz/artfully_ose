Factory.define :order do |o|
  o.association :user
end

Factory.define :order_with_items, :parent => :order do |o|
  o.after_create do |order|
    tickets = 3.times.collect { Factory(:ticket_with_id) }
    Factory(:lock, :tickets => tickets.collect(&:id))
    order.add_tickets tickets
    order.donations << Factory(:donation)
  end
end
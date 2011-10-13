Factory.define :cart do |o|
end

Factory.define :cart_with_items, :parent => :cart do |o|
  o.after_create do |order|
    tickets = 3.times.collect { Factory(:ticket) }
    Factory(:lock, :tickets => tickets.collect(&:id))
    order.add_tickets tickets
    order.donations << Factory(:donation)
  end
end
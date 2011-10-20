Given /^there is an order with (\d+) tickets$/ do |number_of_tickets|
  order = Factory(:order, :organization => @current_user.current_organization)
  items = number_of_tickets.to_i.times.collect { Factory(:item, :order => order) }
  visit order_path(order)
end

Given /^there is an order with (\d+) comps$/ do |number_of_tickets|
  order = Factory(:order, :organization => @current_user.current_organization)
  items = number_of_tickets.to_i.times.collect { Factory(:comped_item, :order => order) }
  visit order_path(order)
end


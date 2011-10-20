Given /^there is an order with (\d+) tickets$/ do |number_of_tickets|
  order = Factory(:order, :organization => @current_user.current_organization)
  items = number_of_tickets.to_i.times.collect { Factory(:item, :order => order) }
  visit order_path(order)
end

Given /^there is an order with an ID of (\d+) with (\d+) comps$/ do |id, number_of_tickets|
  order = Factory(:order, :id => id, :organization => @current_user.current_organization)
  items = number_of_tickets.to_i.times.collect { Factory(:comped_item) }
  visit order_path(id)
end


Given /^there is an order with an ID of (\d+) and (\d+) tickets$/ do |id, number_of_tickets|
  order = Factory(:athena_order, :id => id, :organization => @current_user.current_organization)
  items = number_of_tickets.to_i.times.collect { Factory(:athena_item_with_id) }

  body = items.collect { |i| i.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/orders/items.json?orderId=eq#{order.id}", :body => "[#{body}]")

  FakeWeb.register_uri(:any, "http://localhost/orders/orders/#{order.id}.json", :body => order.encode)
  visit order_path(id)
end

Given /^there is an order with an ID of (\d+) with (\d+) comps$/ do |id, number_of_tickets|
  order = Factory(:athena_order, :id => id, :organization => @current_user.current_organization)
  items = number_of_tickets.to_i.times.collect { Factory(:athena_item_for_comped_ticket) }

  body = items.collect { |i| i.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/orders/items.json?orderId=eq#{order.id}", :body => "[#{body}]")

  FakeWeb.register_uri(:any, "http://localhost/orders/orders/#{order.id}.json", :body => order.encode)
  visit order_path(id)
end


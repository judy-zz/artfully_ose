Given /^there is an order with an ID of (\d+) and (\d+) tickets$/ do |id, number_of_tickets|
  order = Factory(:order, :id => id, :organization => @current_user.current_organization)
  items = number_of_tickets.to_i.times.collect { Factory(:item) }

  body = items.collect { |i| i.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/athena/items.json?orderId=#{order.id}", :body => "[#{body}]")

  FakeWeb.register_uri(:any, "http://localhost/athena/orders/#{order.id}.json", :body => order.encode)
  visit order_path(id)
end

Given /^there is an order with an ID of (\d+) with (\d+) comps$/ do |id, number_of_tickets|
  order = Factory(:order, :id => id, :organization => @current_user.current_organization)
  items = number_of_tickets.to_i.times.collect { Factory(:comped_item) }

  body = items.collect { |i| i.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/athena/items.json?orderId=#{order.id}", :body => "[#{body}]")

  FakeWeb.register_uri(:any, "http://localhost/athena/orders/#{order.id}.json", :body => order.encode)
  visit order_path(id)
end


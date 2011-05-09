Given /^there is an order with an ID of (\d+) and (\d+) tickets$/ do |id, number_of_tickets|
  order = Factory(:athena_order, :id => id, :organization => @current_user.current_organization)
  items = number_of_tickets.to_i.times.collect { Factory(:athena_item_with_id) }

  body = items.collect { |i| i.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/orders/items.json?orderId=eq#{order.id}", :body => "[#{body}]")

  FakeWeb.register_uri(:any, "http://localhost/orders/orders/#{order.id}.json", :body => order.encode)
end

Given /^I look up order (\d+)$/ do |arg1|
  Given %{I am on the orders page}
  Given %{I fill in "search" with "1"}
  Given %{I press "Search"}
end

Given /^there is an order with an ID of (\d+) with (\d+) comps$/ do |id, number_of_tickets|
  order = Factory(:athena_order, :id => id, :organization => @current_user.current_organization)
  items = number_of_tickets.to_i.times.collect { Factory(:athena_item_for_comped_ticket) }

  body = items.collect { |i| i.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/orders/items.json?orderId=eq#{order.id}", :body => "[#{body}]")

  FakeWeb.register_uri(:any, "http://localhost/orders/orders/#{order.id}.json", :body => order.encode)
end

Then /^there should not be any tickets available to exchange$/ do
  page.should have_no_xpath("(//div[@id='exchanges']/form/ul/li)")
end

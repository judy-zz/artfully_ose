When /^I delete the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |pos|  FakeWeb.register_uri(:get, "http://localhost/athena/tickets.json?performanceId=eq#{current_performances[pos.to_i - 1].id}", :body => "[#{body}]")
  current_performances.delete_at(pos.to_i - 1)
  body = current_performances.collect { |p| p.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/athena/performances.json?eventId=eq#{current_event.id}", :body => "[#{body}]")

  within(:xpath, "(//ul[@id='of_performances']/li)[#{pos.to_i}]") do
    click_link "Delete"
  end
end

When /^I view the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |pos|
  @performance = current_performances[pos.to_i - 1]
  within(:xpath, "(//ul[@id='of_performances']/li)[#{pos.to_i}]") do
    click_link "performance-datetime"
  end
end

Then /^I should see (\d+) [Pp]erformances$/ do |count|
  page.should have_xpath("//ul[@id='of_performances']/li", :count => count.to_i)
end

Given /^the (\d+)(?:st|nd|rd|th) [Pp]erformance has had tickets created$/ do |pos|
  current_performances[pos.to_i - 1].state = "built"
  performance = current_performances[pos.to_i - 1]
  FakeWeb.register_uri(:get, "http://localhost/athena/performances/#{performance.id}.json", :body => performance.encode)

  tickets = 5.times.collect { Factory(:ticket_with_id, :event_id => current_event.id, :peformance_id => performance.id) }
  body = tickets.collect { |t| t.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/athena/tickets.json?performanceId=eq#{performance.id}", :body => "[#{body}]")

  body = current_performances.collect { |p| p.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/athena/performances.json?eventId=eq#{current_event.id}", :body => "[#{body}]")
end

Given /^the (\d+)(?:st|nd|rd|th) [Pp]erformance is on sale$/ do |pos|
  current_performances[pos.to_i - 1].state = "on_sale"
  performance = current_performances[pos.to_i - 1]
  FakeWeb.register_uri(:get, "http://localhost/athena/performances/#{performance.id}.json", :body => performance.encode)

  tickets = performance.tickets
  tickets.each { |ticket| ticket.state = "on_sale" }
  body = tickets.collect { |t| t.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/athena/tickets.json?performanceId=eq#{performance.id}", :body => "[#{body}]")

  body = current_performances.collect { |p| p.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/athena/performances.json?eventId=eq#{current_event.id}", :body => "[#{body}]")
end

Then /^I should see not be able to delete the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |pos|
  page.should have_no_xpath "(//tr[position()=#{pos.to_i}]/td[@class='actions']/a[@title='Delete'])"
end

Then /^I should see not be able to edit the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |pos|
  page.should have_no_xpath "(//tr[position()=#{pos.to_i}]/td[@class='actions']/a[@title='Edit'])"
end

Given /^a user@example.com named "([^"]*)" buys (\d+) tickets from the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |name, wanted, pos|
  fname, lname = name.split(" ")
  customer = Factory(:athena_person_with_id, :first_name => fname, :last_name => lname)

  performance = current_performances[pos.to_i - 1]
  tickets = performance.tickets
  tickets.reject { |t| t.state == "sold" }.first(wanted.to_i).each do |ticket|
    ticket.buyer = customer
    ticket.state = "sold"
  end

  body = tickets.collect { |t| t.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/athena/tickets.json?performanceId=eq#{performance.id}", :body => "[#{body}]")
end

When /^I search for the patron named "([^"]*)" email "([^"]*)"$/ do |name, email|
  fname, lname = name.split(" ")
  customer = Factory(:athena_person_with_id, :first_name => fname, :last_name => lname, :email=>email, :organization_id => @current_user.current_organization.id)
  FakeWeb.register_uri(:get, %r|http://localhost/athena/people\.json?.*_q.*|, :body => "[#{customer.encode}]")
  FakeWeb.register_uri(:post, "http://localhost/athena/actions.json", :body => Factory(:athena_purchase_action).encode)

  When %{I fill in "Search" with "#{email}"}
  And %{I press "Search"}
end

When /^I confirm comp$/ do
  customer = Factory(:athena_person_with_id)
  ticket = Factory(:ticket_with_id)
  FakeWeb.register_uri(:get, "http://localhost/athena/orders.json?parentId=1", :body=>"")

  body1 = '{"subjectId":"1","personId":"1","actionType":"purchase","id":"1"}'
  FakeWeb.register_uri(:post, "http://localhost/athena/orders.json", :body => "#{body1}")

  body2 = '{"price":"1","itemType":"AthenaTicket","itemId":"1","orderId":"1","id":"1"}'
  FakeWeb.register_uri(:post, "http://localhost/athena/items.json", :body => "#{body2}")

  FakeWeb.register_uri(:post, "http://localhost/people/actions.json", :body => "#{body1}")

  #FakeWeb.register_uri(:get, "http://localhost/athena/tickets.json?performanceId=eq3", :body=>"")
  #performance = current_performances.first
  #performance.tickets.first.state = "comped"

  And %{I press "Confirm"}
end

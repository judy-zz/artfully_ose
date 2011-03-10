When /^I delete the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |pos|
  current_performances.delete_at(pos.to_i - 1)
  body = current_performances.collect { |p| p.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/stage/performances/.json?eventId=eq#{current_event.id}", :body => "[#{body}]")

  within(:xpath, "(//table[@id='performance-table']/tbody/tr)[#{pos.to_i}]") do
    click_link "Delete"
  end
end

When /^I view the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |pos|
  within(:xpath, "(//table[@id='performance-table']/tbody/tr)[#{pos.to_i}]") do
    click_link "View Tickets"
  end
end

Then /^I should see (\d+) [Pp]erformances$/ do |count|
  page.should have_xpath("//table[@id='performance-table']/tbody/tr", :count => count.to_i)
end

Given /^the (\d+)(?:st|nd|rd|th) [Pp]erformance has had tickets created$/ do |pos|
  current_performances[pos.to_i - 1].state = "built"
  performance = current_performances[pos.to_i - 1]
  FakeWeb.register_uri(:get, "http://localhost/stage/performances/#{performance.id}.json", :body => performance.encode)

  tickets = 5.times.collect { Factory(:ticket_with_id, :performance_id => performance.id) }
  body = tickets.collect { |t| t.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/tix/tickets/.json?performanceId=eq#{performance.id}", :body => "[#{body}]")

  body = current_performances.collect { |p| p.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/stage/performances/.json?eventId=eq#{current_event.id}", :body => "[#{body}]")
end

Given /^the (\d+)(?:st|nd|rd|th) [Pp]erformance is on sale$/ do |pos|
  current_performances[pos.to_i - 1].state = "on_sale"
  performance = current_performances[pos.to_i - 1]
  FakeWeb.register_uri(:get, "http://localhost/stage/performances/#{performance.id}.json", :body => performance.encode)

  tickets = performance.tickets
  tickets.each { |ticket| ticket.on_sale = true }
  body = tickets.collect { |t| t.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/tix/tickets/.json?performanceId=eq#{performance.id}", :body => "[#{body}]")

  body = current_performances.collect { |p| p.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/stage/performances/.json?eventId=eq#{current_event.id}", :body => "[#{body}]")
end

Then /^I should see not be able to delete the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |pos|
  page.should have_no_xpath "(//tr[position()=#{pos.to_i}]/td[@class='actions']/a[@title='Delete'])"
end

Then /^I should see not be able to edit the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |pos|
  page.should have_no_xpath "(//tr[position()=#{pos.to_i}]/td[@class='actions']/a[@title='Edit'])"
end

Given /^a patron named "([^"]*)" buys (\d+) tickets from the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |name, wanted, pos|
  fname, lname = name.split(" ")
  customer = Factory(:athena_person_with_id, :first_name => fname, :last_name => lname)

  performance = current_performances[pos.to_i - 1]
  tickets = performance.tickets
  tickets.reject { |t| t.sold? }.first(wanted.to_i).each do |ticket|
    ticket.buyer = customer
    ticket.state = "sold"
  end

  body = tickets.collect { |t| t.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/tix/tickets/.json?performanceId=eq#{performance.id}", :body => "[#{body}]")
end


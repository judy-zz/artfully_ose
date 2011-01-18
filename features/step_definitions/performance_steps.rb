When /^I delete the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |pos|
  @performances.delete_at(pos.to_i)
  body = @performances.collect { |p| p.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/stage/performances/.json?eventId=eq#{@event.id}", :status => 200, :body => "[#{body}]")

  within(:xpath, "(//table[@id='performance-table']/tbody/tr)[#{pos.to_i}]") do
    click_link "Delete"
  end
end

Then /^I should see (\d+) [Pp]erformances$/ do |count|
  page.should have_xpath("//table[@id='performance-table']/tbody/tr", :count => count.to_i)
end

Given /^the (\d+)(?:st|nd|rd|th) [Pp]erformance has had tickets created$/ do |pos|
  @performances[pos.to_i - 1].tickets_created = true
  body = @performances.collect { |p| p.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/stage/performances/.json?eventId=eq#{@event.id}", :status => 200, :body => "[#{body}]")
end

Given /^the (\d+)(?:st|nd|rd|th) [Pp]erformance is on sale$/ do |pos|
  @performances[pos.to_i - 1].on_sale = true
  body = @performances.collect { |p| p.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/stage/performances/.json?eventId=eq#{@event.id}", :status => 200, :body => "[#{body}]")
end

Then /^I should see not be able to delete the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |pos|
  page.should have_no_xpath "(//tr[position()=#{pos.to_i}]/td[@class='actions']/a[@title='Delete'])"
end

Then /^I should see not be able to edit the (\d+)(?:st|nd|rd|th) [Pp]erformance$/ do |pos|
  page.should have_no_xpath "(//tr[position()=#{pos.to_i}]/td[@class='actions']/a[@title='Edit'])"
end

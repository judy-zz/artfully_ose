Given /^the following event exists with (\d+) performance for producer with id of (\d+):$/ do |performance_count, producer_id, table|
  event = Factory(:athena_event, table.hashes.first)
  FakeWeb.register_uri(:any, "http://localhost/stage/events/#{event.id}.json", :status => 200, :body => event.encode)
  FakeWeb.register_uri(:get, "http://localhost/stage/events/.json?producerId=eq#{producer_pid}", :status => 200, :body => "[#{event.encode}]")

  performances = "["
  performance_count.to_i.times do
    performance = Factory(:athena_performance, :event_id => event.id)
    FakeWeb.register_uri(:any, "http://localhost/stage/performances/1.json", :status => 200, :body => performance.encode)
    performances << performance.encode
  end
  performances << "]"

  FakeWeb.register_uri(:get, "http://localhost/stage/performances/.json?eventId=eq#{event.id}", :status => 200, :body => performances)
end

Then /^the response should be JSON with callback "([^"]*)" for the following events:$/ do |callback, table|
  events = []
  table.hashes.each do |hash|
    events << Factory(:athena_event, hash)
  end

  body = /#{callback}\((.*)\);/.match(last_response.body)
  content = JSON.parse(body[1])
  event = Factory(:athena_event, content)
  event.should == events.first
end

When /^I select performance (\d+) for event (\d+) in the event widget$/ do |performance_id, event_id|
  FakeWeb.register_uri(:any, "http://localhost/tix/tickets/.json?performanceId=eq", :status => 200, :body => "[]")
  visit "/events/#{event_id}/performances/#{performance_id}.widget"
end

Given /^the following event exists in ATHENA for "([^"]*)"$/ do |email, table|
  @event = Factory(:athena_event, table.hashes.first)
  @event.id = 1
  @user = User.find_by_email(email)
  @event.producer_pid = @user.athena_id
  FakeWeb.register_uri(:get, "http://localhost/stage/events/.json?producerPid=eq#{@user.athena_id}", :status => 200, :body => "[#{@event.encode}]")
  FakeWeb.register_uri(:any, "http://localhost/stage/events/#{@event.id}.json", :status => 200, :body => @event.encode)
  FakeWeb.register_uri(:get, "http://localhost/stage/performances/.json?eventId=eq#{@event.id}", :status => 200, :body => "[]")
  FakeWeb.register_uri(:get, "http://localhost/stage/charts/.json?eventId=eq#{@event.id}", :status => 200, :body => "[]")
  FakeWeb.register_uri(:get, "http://localhost/stage/charts/.json?producerPid=eq#{@user.athena_id}&isTemplate=eqtrue", :status => 200, :body => "[]")
end

Given /^there is an [Ee]vent with (\d+) [Pp]erformances for "([^"]*)"$/ do |performance_count, email|
  user = User.find_by_email(email)

  @event = Factory(:athena_event_with_id, :producer_pid => user.athena_id)
  FakeWeb.register_uri(:get, "http://localhost/stage/events/.json?producerPid=eq#{user.athena_id}", :status => 200, :body => "[#{@event.encode}]")

  chart = Factory(:athena_chart, :producer_pid => user.athena_id)
  FakeWeb.register_uri(:get, "http://localhost/stage/charts/.json?eventId=eq#{@event.id}", :status => 200, :body => "[#{chart.encode}]")
  FakeWeb.register_uri(:get, "http://localhost/stage/sections/.json?chartId=eq#{chart.id}", :status => 200, :body => "[#{Factory(:athena_section_with_id).encode}]")

  @performances = 3.times.collect { Factory(:athena_performance_with_id, :event => @event, :chart => chart, :producer_pid => user.athena_id) }
  body = @performances.collect { |p| p.encode }.join(",")
  FakeWeb.register_uri(:get, "http://localhost/stage/performances/.json?eventId=eq#{@event.id}", :status => 200, :body => "[#{body}]")

  visit events_path
  FakeWeb.register_uri(:get, "http://localhost/stage/charts/.json?producerPid=eq#{user.athena_id}&isTemplate=eqtrue", :status => 200, :body => "[]")
  Given %{I follow "#{@event.name}"}
end

Given /^I view the (\d+)(?:st|nd|rd|th) [Ee]vent$/ do |pos|
  within(:xpath, "(//tbody/tr)[#{pos.to_i}]") do
    click_link "event-name"
  end
end
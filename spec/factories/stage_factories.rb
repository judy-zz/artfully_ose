Factory.sequence :chart_id do |n|
  n
end

Factory.define :athena_chart, :default_strategy => :build do |c|
  c.id { Factory.next :chart_id }
  c.organization_id { Factory(:organization).id }
  c.name 'Test Chart'
  c.is_template false
  c.sections { 2.times.collect { Factory(:athena_section_with_id) } }

  c.after_build do |chart|
    FakeWeb.register_uri(:get, "http://localhost/athena/charts/#{chart.id}.json", :body => chart.encode)
    FakeWeb.register_uri(:post, "http://localhost/athena/charts.json", :body => chart.encode)
    FakeWeb.register_uri(:put, "http://localhost/athena/charts/#{chart.id}.json", :body => chart.encode)
  end
end

Factory.define :athena_chart_template, :parent => :athena_chart do |c|
  c.is_template true
end

Factory.sequence :section_id do |n|
  n
end

Factory.define :athena_free_section, :class => AthenaSection, :default_strategy => :build do |section|
  section.name 'Balcony'
  section.capacity 5
  section.price 0
end

Factory.define :athena_section, :class => AthenaSection, :default_strategy => :build do |section|
  section.name 'Balcony'
  section.capacity "5"
  section.price 5000
end

Factory.define :athena_section_with_id, :parent => :athena_section do |section|
  section.id { Factory.next(:section_id) }
  section.after_build do |section|
    FakeWeb.register_uri(:get, "http://localhost/athena/sections/#{section.id}.json", :body => section.encode)
    FakeWeb.register_uri(:put, "http://localhost/athena/sections/#{section.id}.json", :body => section.encode)
  end
end

Factory.sequence :event_id do |id|
  id
end

Factory.define :athena_event, :default_strategy => :build do |e|
  e.name "Some Event"
  e.venue "Some Venue"
  e.city "Some City"
  e.state "Some State"
  e.producer "Some Producer"
  e.time_zone "Hawaii"
  e.organization_id { Factory(:organization).id }
end

Factory.define :athena_event_with_id, :parent => :athena_event do |e|
  e.id { Factory.next :event_id }
  e.after_build do |event|
    FakeWeb.register_uri(:post, "http://localhost/athena/events.json", :body => event.encode)
    FakeWeb.register_uri(:any, "http://localhost/athena/events/#{event.id}.json", :body => event.encode)
    body = '{"performancesOnSale":2,"revenue":{"advanceSales":{"gross":0.0,"net":0.0},"soldToday":{"gross":0.0,"net":0.0},"potentialRemaining":{"gross":62500.0,"net":0.0},"originalPotential":{"gross":62500.0,"net":0.0},"totalSales":{"gross":0.0,"net":0.0},"totalPlayed":{"gross":0.0,"net":0.0}},"tickets":{"sold":{"gross":0,"comped":0},"soldToday":{"gross":0,"comped":0},"played":{"gross":0,"comped":0},"available":0}}'
    FakeWeb.register_uri(:get, %r|http://localhost/athena/reports/glance/\.json\?.*eventId=.*|, :body => body)
  end
end

Factory.sequence :performance_datetime do |n|
  (DateTime.now + n.days)
end

Factory.sequence :performance_id do |id|
  id
end

Factory.define :athena_performance, :default_strategy => :build do |p|
  p.datetime { Factory.next :performance_datetime }
  p.event { Factory(:athena_event_with_id) }
  p.organization_id { Factory(:organization).id }
end

Factory.define :athena_performance_with_id, :parent => :athena_performance do |p|
  p.id { Factory.next :performance_id }
  p.chart_id "4"
  p.after_build do |performance|
    FakeWeb.register_uri(:any, "http://localhost/athena/performances/#{performance.id}.json", :body => performance.encode)
    body= '{"revenue":{"soldToday":{"gross":0.0,"net":0.0},"potentialRemaining":{"gross":0.0,"net":0.0},"originalPotential":{"gross":0.0,"net":0.0},"totalSales":{"gross":0.0,"net":0.0}},"tickets":{"sold":{"gross":0,"comped":0},"soldToday":{"gross":0,"comped":0},"available":0}}'
    FakeWeb.register_uri(:get, %r|http://localhost/athena/reports/glance/\.json\?.*performanceId=.*|, :body => body)
  end
end
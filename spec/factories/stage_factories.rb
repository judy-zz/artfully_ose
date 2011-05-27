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
    FakeWeb.register_uri(:get, "http://localhost/stage/charts/#{chart.id}.json", :body => chart.encode)
    FakeWeb.register_uri(:post, "http://localhost/stage/charts.json", :body => chart.encode)
    FakeWeb.register_uri(:put, "http://localhost/stage/charts/#{chart.id}.json", :body => chart.encode)
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
  section.capacity 5
  section.price 5000
end

Factory.define :athena_section_with_id, :parent => :athena_section do |section|
  section.id { Factory.next(:section_id) }
  section.after_build do |section|
    FakeWeb.register_uri(:get, "http://localhost/stage/sections/#{section.id}.json", :body => section.encode)
    FakeWeb.register_uri(:put, "http://localhost/stage/sections/#{section.id}.json", :body => section.encode)
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
    FakeWeb.register_uri(:post, "http://localhost/stage/events.json", :body => event.encode)
    FakeWeb.register_uri(:any, "http://localhost/stage/events/#{event.id}.json", :body => event.encode)
    body = '{"performancesOnSale":40,"revenue":{"advanceSales":{"gross":300.0,"net":270.0},"soldToday":{"gross":90.0,"net":81.0},"potentialRemaining":{"gross":2885.74,"net":2558.33},"originalPotential":{"gross":29635.55,"net":19885.02},"totalSales":{"gross":9959.99,"net":4562.25},"totalPlayed":{"gross":4500.44,"net":4000.8}},"tickets":{"sold":{"gross":100,"comped":20},"soldToday":{"gross":10,"comped":0},"played":{"gross":9},"available":65}}'
    FakeWeb.register_uri(:get, "http://localhost/reports/glance/.json?eventId=#{event.id}", :body => body)
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
end

Factory.define :athena_performance_with_id, :parent => :athena_performance do |p|
  p.id { Factory.next :performance_id }
  p.after_build do |performance|
    FakeWeb.register_uri(:any, "http://localhost/stage/performances/#{performance.id}.json", :body => performance.encode)
    body = '{"revenue":{"advanceSales":{"gross":300.0,"net":270.0},"soldToday":{"gross":90.0,"net":81.0},"potentialRemaining":{"gross":2885.74,"net":2558.33},"originalPotential":{"gross":29635.55,"net":19885.02},"totalSales":{"gross":9959.99,"net":4562.25}},"tickets":{"sold":{"gross":100,"comped":20},"soldToday":{"gross":10,"comped":0},"available":65}}'
    FakeWeb.register_uri(:get, "http://localhost/reports/glance/.json?performanceId=#{performance.id}", :body => body)
  end
end

Factory.define :athena_chart, :class => AthenaChart, :default_strategy => :build do |c|
  c.id 300
  c.producer_pid 3220
  c.name 'test chart'
  c.is_template false

  c.after_build do |chart|
    FakeWeb.register_uri(:get, "http://localhost/stage/charts/#{chart.id}.json", :status => 200, :body => chart.encode)
    FakeWeb.register_uri(:post, "http://localhost/stage/charts/.json", :status => 200, :body => chart.encode)
    FakeWeb.register_uri(:put, "http://localhost/stage/charts/#{chart.id}.json", :status => 200, :body => chart.encode)
  end
end

Factory.define :athena_chart_template, :parent => :athena_chart do |c|
  c.is_template true
end

Factory.define :athena_section_orchestra, :class => AthenaSection, :default_strategy => :build do |section|
  section.id 44
  section.name 'Orchestra'
  section.capacity 10
  section.price 50
  section.after_build do |section|
    FakeWeb.register_uri(:get, "http://localhost/stage/sections/#{section.id}.json", :status => 200, :body => section.encode)
    FakeWeb.register_uri(:put, "http://localhost/stage/sections/#{section.id}.json", :status => 200, :body => section.encode)
  end
end

Factory.define :athena_section_balcony, :class => AthenaSection, :default_strategy => :build do |section|
  section.id 45
  section.name 'Balcony'
  section.capacity 5
  section.price 5
  section.after_build do |section|
    FakeWeb.register_uri(:get, "http://localhost/stage/sections/#{section.id}.json", :status => 200, :body => section.encode)
    FakeWeb.register_uri(:put, "http://localhost/stage/sections/#{section.id}.json", :status => 200, :body => section.encode)
  end
end

Factory.sequence :event_id do |id|
  id
end

Factory.define :athena_event, :default_strategy => :build do |e|
  e.name "Some Event"
  e.venue "Some Venue"
  e.producer "Some Producer"
end

Factory.define :athena_event_with_id, :parent => :athena_event do |e|
  e.id { Factory.next :event_id }
  e.after_build do |event|
    FakeWeb.register_uri(:post, "http://localhost/stage/events/.json", :status => 200, :body => event.encode)
    FakeWeb.register_uri(:any, "http://localhost/stage/events/#{event.id}.json", :status => 200, :body => event.encode)
  end
end



Factory.sequence :performance_datetime do |n|
  "2011-03-#{n}T10:10:00-04:00"
end

Factory.sequence :performance_id do |id|
  id
end

Factory.define :athena_performance, :default_strategy => :build do |p|
  p.datetime Factory.next :performance_datetime
end

Factory.define :athena_performance_with_id, :parent => :athena_performance do |p|
  p.id { Factory.next :performance_id }
  p.after_build do |performance|
    FakeWeb.register_uri(:get, "http://localhost/stage/performances/#{performance.id}.json", :status => 200, :body => performance.encode)
    FakeWeb.register_uri(:delete, "http://localhost/stage/performances/#{performance.id}.json", :status => 200, :body => "")
  end
end
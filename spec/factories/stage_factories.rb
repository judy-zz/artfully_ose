Factory.sequence :chart_id do |n|
  n
end

Factory.define :athena_chart, :class => AthenaChart, :default_strategy => :build do |c|
  c.id { Factory.next :chart_id }
  c.producer_pid { Factory.next :person_id }
  c.name 'Test Chart'
  c.is_template false
  c.sections { 2.times.collect { Factory(:athena_section_with_id) } }

  c.after_build do |chart|
    FakeWeb.register_uri(:get, "http://localhost/stage/charts/#{chart.id}.json", :status => 200, :body => chart.encode)
    FakeWeb.register_uri(:post, "http://localhost/stage/charts/.json", :status => 200, :body => chart.encode)
    FakeWeb.register_uri(:put, "http://localhost/stage/charts/#{chart.id}.json", :status => 200, :body => chart.encode)
  end
end

Factory.define :athena_chart_template, :parent => :athena_chart do |c|
  c.is_template true
end

Factory.sequence :section_id do |n|
  n
end

Factory.define :athena_section, :class => AthenaSection, :default_strategy => :build do |section|
  section.name 'Balcony'
  section.capacity 5
  section.price 5
end

Factory.define :athena_section_with_id, :parent => :athena_section do |section|
  section.id { Factory.next(:section_id) }
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
  e.producer_pid { Factory(:athena_person_with_id).id }
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
  p.datetime Factory.next :performance_datetime
  p.after_build do |performance|
    FakeWeb.register_uri(:get, "http://localhost/stage/performances/#{performance.id}.json", :status => 200, :body => performance.encode)
    FakeWeb.register_uri(:delete, "http://localhost/stage/performances/#{performance.id}.json", :status => 200, :body => "")
  end
end
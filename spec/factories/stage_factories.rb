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
  n.to_s
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


Factory.define :event do |e|
  e.name "Some Event"
  e.venue "Some Venue"
  e.city "Some City"
  e.state "Some State"
  e.producer "Some Producer"
  e.time_zone "Hawaii"
  e.association :organization
end

Factory.sequence :datetime do |n|
  (DateTime.now + n.days)
end

Factory.define(:show) do |p|
  p.datetime { Factory.next :datetime }
  p.association :organization
  # TODO
  p.chart_id 1
end

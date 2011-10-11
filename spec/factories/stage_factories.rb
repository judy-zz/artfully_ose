Factory.define :chart do |c|
  c.name 'Test Chart'
  c.is_template false
  c.association :organization
end

Factory.define :chart_template, :parent => :chart do |c|
  c.is_template true
end

Factory.define :section do |s|
  s.name "General"
  s.capacity 1
  s.price 0
end

Factory.define :free_section, :class => Section do |section|
  section.name 'Balcony'
  section.capacity 5
  section.price 0
end

Factory.define :athena_section, :class => Section do |section|
  section.name 'Balcony'
  section.capacity 5
  section.price 5000
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

Factory.define :section do |s|
  s.name "General"
  s.capacity 5
  s.price 1000
end

Factory.define :free_section, :class => Section do |section|
  section.name 'Balcony'
  section.capacity 5
  section.price 0
end

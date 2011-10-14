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

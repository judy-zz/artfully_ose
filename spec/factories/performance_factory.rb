Factory.sequence :title do |n|
  "Title#{n}"
end

Factory.define :performance do |p|
  p.title { Factory.next :title }
  p.venue "Test Venue"
  p.performed_on { Time.now }
end

Factory.define :event do |e|
  e.name "Some Event"
  e.venue "Some Venue"
  e.city "Some City"
  e.state "Some State"
  e.producer "Some Producer"
  e.time_zone "Hawaii"
  e.association :organization
end

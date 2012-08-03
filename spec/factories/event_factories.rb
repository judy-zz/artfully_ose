Factory.define :event do |e|
  e.name "Some Event"
  e.producer "Some Producer"
  e.association :organization
  e.association :venue
end

Factory.define :paid_event, :parent => :event do |e|
  e.after_create do |event|
    event.is_free = false
  end
end

Factory.define :free_event, :parent => :event do |e|
  e.after_create do |event|
    event.is_free = true
  end
end

Factory.define :venue do |venue|
  venue.name            "Venue Theater"
  venue.address1        { Faker::Address.street_address }
  venue.address2        { Faker::Address.secondary_address }
  venue.city            { Faker::Address.city }
  venue.state           { Faker::Address.us_state }
  venue.zip             { Faker::Address.zip_code }
  venue.country         "United States"
  venue.time_zone       "Mountain Time (US & Canada)"
end

FactoryGirl.define do
  factory :event do
    name "Some Event"
    producer "Some Producer"
    association :organization
    association :venue
  end

  factory :paid_event, :parent => :event do
    after(:create) do |event|
      event.is_free = false
    end
  end

  factory :free_event, :parent => :event do
    after(:create) do |event|
      event.is_free = true
    end
  end

  factory :venue do
    name            "Venue Theater"
    address1        { Faker::Address.street_address }
    address2        { Faker::Address.secondary_address }
    city            { Faker::Address.city }
    state           { Faker::Address.us_state }
    zip             { Faker::Address.zip_code }
    country         "United States"
    time_zone       "Mountain Time (US & Canada)"
  end

end
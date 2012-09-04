require 'ostruct'
FactoryGirl.define do
  factory :credit_card_payment do
    amount 100
  end

  factory :payment do
    amount 100
    customer { OpenStruct.new.tap {|c|
      c.first_name  = Faker::Name.first_name
      c.last_name   = Faker::Name.last_name
      c.phone       = Faker::PhoneNumber.phone_number
      c.email       = Faker::Internet.email
    } }
  end
end


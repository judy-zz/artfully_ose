require 'ostruct'
FactoryGirl.define do
  factory :customer, class: OpenStruct do
    first_name = Faker::Name.first_name
    last_name   = Faker::Name.last_name
    phone       = Faker::PhoneNumber.phone_number
    email       = Faker::Internet.email
  end

  factory :credit_card_payment do
    amount 100
  end

  sequence(:customer_id) {|n| n }

  factory :customer_with_id, :parent => :customer do
    id { FactoryGirl.generate :customer_id }
    after(:build) do |customer|
      FakeWeb.register_uri(:post, "http://localhost/payments/customers.json", :body => customer.encode)
      FakeWeb.register_uri(:get, "http://localhost/payments/customers/#{customer.id}.json", :body => customer.encode)
    end
  end

  factory :customer_with_id_and_person_id, :parent => :customer do
    id { FactoryGirl.generate :customer_id }
    person_id 9
    after(:build) do |customer|
      FakeWeb.register_uri(:post, "http://localhost/payments/customers.json", :body => customer.encode)
      FakeWeb.register_uri(:get, "http://localhost/payments/customers/#{customer.id}.json", :body => customer.encode)
    end
  end

  factory :payment do
    amount 100
    customer
  end
end


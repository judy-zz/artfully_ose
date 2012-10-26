FactoryGirl.define do
  factory :ticket do
    venue { Faker::Lorem.words(2).join(" ") + " Theatre"}
    initial_price 5000
    price 5000
    show
    organization
    section
  end

  factory :free_ticket, :parent => :ticket do
    venue { Faker::Lorem.words(2).join(" ") + " Theatre"}
    initial_price 0
    price 0
    show
    organization
  end

  factory :comped_ticket, :parent => :ticket do
    after(:create) do |ticket|
      ticket.comp_to :person
    end
  end

  factory :sold_ticket, :parent => :ticket do
    state :sold
    after(:create) do |ticket|
      ticket.sell_to FactoryGirl.create(:person)
    end
  end
end
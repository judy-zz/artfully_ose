FactoryGirl.define do
  factory :ticket do
    venue { Faker::Lorem.words(2).join(" ") + " Theatre"}
    price 5000
    association :show
    association :organization
    association :section
  end

  factory :free_ticket, :parent => :ticket do
    venue { Faker::Lorem.words(2).join(" ") + " Theatre"}
    price 0
    association :show
    association :organization
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
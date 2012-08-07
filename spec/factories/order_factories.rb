FactoryGirl.define do
  factory :order do
    transaction_id "j59qrb"
    price 50
    association :person
    association :organization
  end
end

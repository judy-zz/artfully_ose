FactoryGirl.define do
  factory :order do
    transaction_id "j59qrb"
    price 50
    association :person
    association :organization
  end
  
  factory :order_with_processing_charge, :parent => :order do
    after(:create) do |order|
      order.per_item_processing_charge = lambda { |item| item.realized_price * 0.035 }
    end    
  end
end

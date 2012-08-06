FactoryGirl.define do
FactoryGirl.define do
  factory :section do
    name "General"
    capacity 5
    price 1000
  end

  factory :free_section, :class => Section do
    name 'Balcony'
    capacity 5
    price 0
  end
end

end
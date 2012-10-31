FactoryGirl.define do
  factory :discount do
    active true
    code { (5...10).inject(""){|s, _| s << 65.+(rand(26)).chr} }
    promotion_type "TenPercentOffTotal"
    event
    organization
    creator { build(:user) }
  end
end

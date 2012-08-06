FactoryGirl.define do
factory :organization do
  name { Faker::Company.name }
end

factory :organization_with_timezone, :parent => :organization do
  time_zone 'Eastern Time (US & Canada)'
end

factory :organization_with_bank_account, :parent => :organization do
  after(:create) do |organization|
    organization.bank_account = Factory(:bank_account)
  end
end

factory :organization_with_ticketing, :parent => :organization do
  after(:create) { |organization| Factory(:ticketing_kit, :state => :activated, :organization => organization) }
end

factory :organization_with_reselling, :parent => :organization do
  after(:create) { |org| Factory(:reseller_kit, :state => :activated, :organization => org) }
  after(:create) { |org| Factory(:reseller_profile, :organization => org) }
end

factory :organization_with_donations, :parent => :organization do
  after(:create) { |organization| Factory(:regular_donation_kit, :state => :activated, :organization => organization) }
end

factory :connected_organization, :parent => :organization do
  association :fiscally_sponsored_project
  fa_member_id "1"
end

end
Factory.define :organization do |o|
  o.name { Faker::Company.name }
end

Factory.define(:organization_with_bank_account, :parent => :organization) do |o|
  o.after_create do |organization|
    organization.bank_account = Factory(:bank_account)
  end
end

Factory.define :organization_with_ticketing, :parent => :organization do |o|
  o.after_create { |organization| Factory(:ticketing_kit, :state => :activated, :organization => organization) }
end

Factory.define :organization_with_donations, :parent => :organization do |o|
  o.after_create { |organization| Factory(:regular_donation_kit, :state => :activated, :organization => organization) }
end

Factory.define(:connected_organization, :parent => :organization) do |o|
  o.association :fiscally_sponsored_project
  o.fa_member_id "1"
end

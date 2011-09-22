Factory.define :organization do |o|
  o.name { Faker::Company.name }
  o.after_create do |organization|
    FakeWeb.register_uri(:get, "http://localhost/athena/events.json?organizationId=#{organization.id}", :body => "[]")
  end
end

Factory.define :organization_with_id, :parent => :organization do |o|
  o.id 19
end

Factory.define :organization_with_ticketing, :parent => :organization do |o|
  o.after_create { |organization| Factory(:ticketing_kit, :state => :activated, :organization => organization) }
end

Factory.define :organization_with_donations, :parent => :organization do |o|
  o.after_create { |organization| Factory(:regular_donation_kit, :state => :activated, :organization => organization) }
end

Factory.define :fiscally_sponsored_project do |fsp|
  fsp = FiscallySponsoredProject.new
end

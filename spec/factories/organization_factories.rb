Factory.define :organization do |o|
  o.name { Faker::Company.name }
end

Factory.define :organization_with_ticketing, :parent => :organization do |o|
  o.after_create { |organization| Factory(:ticketing_kit, :state => :activated, :organization => organization) }
end

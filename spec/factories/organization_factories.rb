Factory.define :organization do |o|
  o.name { Faker::Company.name }
end
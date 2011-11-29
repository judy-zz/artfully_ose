Factory.define :person do |p|
  p.email           { Faker::Internet.email}
  p.first_name      { Faker::Name.first_name }
  p.last_name       { Faker::Name.last_name }
  p.association     :organization
end

Factory.define :person_without_email, :parent => :person do |p|
  p.email nil
end

Factory.define(:dummy, :parent => :person) do |p|
  p.dummy true
end
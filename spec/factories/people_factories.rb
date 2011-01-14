Factory.sequence :person_id do |n|
  n
end

Factory.define :person, :class => AthenaPerson, :default_strategy => :build do |p|
  p.email { Faker::Internet.email}
end

Factory.define :person_with_id, :parent => :person do |p|
  p.id { Factory.next :person_id }
end

Factory.define :athena_person, :default_strategy => :build do |p|
  p.email { Faker::Internet.email }
end
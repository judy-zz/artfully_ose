Factory.sequence :person_id do |n|
  n
end

Factory.define :athena_person, :default_strategy => :build do |p|
  p.email { Faker::Internet.email }
end

Factory.define :athena_person_with_id, :parent => :athena_person do |p|
  p.id { Factory.next :person_id }
  p.after_build { |p| FakeWeb.register_uri(:any, "http://localhost/people/people/#{p.id}.json", :body => p.encode) }
end
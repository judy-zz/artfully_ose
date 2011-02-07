Factory.sequence :person_id do |n|
  n
end

Factory.define :athena_person, :default_strategy => :build do |p|
  p.email { Faker::Internet.email}
end

Factory.define :athena_person_with_id, :parent => :athena_person do |p|
  p.id { Factory.next :person_id }
  p.after_build do |person|
    FakeWeb.register_uri(:get, "http://localhost/people/people/#{person.id}.json", :body => person.encode)
    FakeWeb.register_uri(:get, "http://localhost/people/people/.json?email=eq#{CGI::escape(person.email)}", :body => "[#{person.encode}]")
  end
end
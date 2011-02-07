Factory.define :user do |u|
  u.email { Faker::Internet.email }
  u.password 'password'
  u.after_build do |user|
    person = Factory(:athena_person_with_id, :email => user.email)
    FakeWeb.register_uri(:post, 'http://localhost/people/people/.json', :body => person.encode)
  end
end

Factory.define :admin, :parent => :user do |u|
  u.after_create { |user| user.roles << ( Role.find_by_name(:admin) || Factory(:admin_role) ) }
end

Factory.define :producer, :parent => :user do |u|
  u.after_create { |user| user.roles << ( Role.find_by_name(:producer) || Factory(:producer_role) ) }
end

Factory.define :patron, :parent => :user do |u|
  u.after_create { |user| user.roles << ( Role.find_by_name(:patron) || Factory(:patron_role) ) }
end

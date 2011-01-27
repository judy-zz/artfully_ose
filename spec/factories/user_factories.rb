Factory.define :user do |u|
  u.email { Faker::Internet.email }
  u.password 'password'
  u.after_build { FakeWeb.register_uri(:any, 'http://localhost/people/people/.json',
                                       :status => 200,
                                       :body => Factory(:athena_person_with_id).encode) }
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

Factory.define :user do |u|
  u.email { Faker::Internet.email }
  u.password 'password'
end

Factory.define :user_with_organization, :parent => :user do |u|
  u.organizations { [ Factory(:organization) ] }
end

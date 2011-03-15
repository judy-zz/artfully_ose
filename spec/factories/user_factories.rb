Factory.define :user do |u|
  u.email { Faker::Internet.email }
  u.password 'password'
end

Factory.define :admin, :parent => :user do |u|
  u.after_create { |user| user.roles << ( Role.find_by_name(:admin) || Factory(:admin_role) ) }
end

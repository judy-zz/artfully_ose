Factory.define :user do |u|
  u.email { Faker::Internet.email }
  u.password 'password'
end

Factory.define :admin, :parent => :user do |u|
  u.after_create do |user|
    user.roles << :admin
    user.save
  end
end

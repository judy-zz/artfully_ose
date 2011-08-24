Factory.define :admin do |u|
  u.email { Faker::Internet.email }
  u.password 'password'
end

Factory.sequence :email do |n|
  "test#{n}@test.com"
end

Factory.define :user do |u|
  u.email { Factory.next :email }
  u.password 'password'
end

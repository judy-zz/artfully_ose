Factory.define :user do |u|
  u.email { Faker::Internet.email }
  u.password 'password'
end

Factory.define(:user_in_organization, :parent => :user) do |u|
  u.after_create do |user|
    user.organizations << Factory(:organization)
  end
end
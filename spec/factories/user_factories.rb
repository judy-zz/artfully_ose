Factory.define :user do |u|
  u.email { Faker::Internet.email }
  u.password 'password'
  
  u.after_build do |user|
    user.stub(:push_to_mailchimp).and_return(false)
  end
  
end

Factory.define(:user_in_organization, :parent => :user) do |u|
  u.after_create do |user|
    user.organizations << Factory(:organization)
  end
end
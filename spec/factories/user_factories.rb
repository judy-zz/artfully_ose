FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'password'
    
    after(:build) do |user|
      user.stub(:push_to_mailchimp).and_return(false)
    end
    
  end

  factory :user_in_organization, :parent => :user do
    after(:create) do |user|
      user.organizations << Factory(:organization)
    end
  end
end

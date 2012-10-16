FactoryGirl.define do
  factory :import do
    s3_bucket   { "example-bucket" }
    s3_key      { "example-key" }
    s3_etag     { Digest::MD5.hexdigest("value") }
  end
  
  factory :donations_import, :class => DonationsImport do
    user { FactoryGirl.create :user_in_organization }
    s3_bucket { "example-bucket" }
    s3_key { "example-key" }
    s3_etag { Digest::MD5.hexdigest("value") }
    
    after(:build) do |import|
      import.organization = import.user.memberships.first.organization
    end
    
  end
  
  factory :events_import, :class => EventsImport do
    user { FactoryGirl.create :user_in_organization }
    s3_bucket { "example-bucket" }
    s3_key { "example-key" }
    s3_etag { Digest::MD5.hexdigest("value") }
    
    after(:build) do |import|
      import.organization = import.user.memberships.first.organization
    end
    
  end
  
  factory :people_import do
    user { FactoryGirl.create :user_in_organization }
    s3_bucket { "example-bucket" }
    s3_key { "example-key" }
    s3_etag { Digest::MD5.hexdigest("value") }
    
    after(:build) do |import|
      import.organization = import.user.memberships.first.organization
    end
    
  end
end
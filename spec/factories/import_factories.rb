FactoryGirl.define do
  factory :import do
    user { FactoryGirl.build(:user_in_organization) }
    s3_bucket { "example-bucket" }
    s3_key { "example-key" }
    s3_etag { Digest::MD5.hexdigest("value") }
  end

end
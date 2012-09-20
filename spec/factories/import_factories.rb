FactoryGirl.define do
  factory :import do
    s3_bucket   { "example-bucket" }
    s3_key      { "example-key" }
    s3_etag     { Digest::MD5.hexdigest("value") }
  end

end
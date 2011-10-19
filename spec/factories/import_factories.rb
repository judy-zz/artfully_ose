Factory.define :import do |f|
  f.user { Factory(:user_with_organization) }
  f.s3_bucket { "example-bucket" }
  f.s3_key { "example-key" }
  f.s3_etag { Digest::MD5.hexdigest("value") }
end

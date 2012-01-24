class ResellerAttachment < ActiveRecord::Base

  belongs_to :reseller_profile
  belongs_to :attachable, :polymorphic => true

  has_attached_file :image,
    :storage => :s3,
    :path => ":attachment/:id/:style.:extension",
    :bucket => ENV["S3_BUCKET"],
    :s3_credentials => {
      :access_key_id => ENV["ACCESS_KEY_ID"],
      :secret_access_key => ENV["SECRET_ACCESS_KEY"]
    }

end

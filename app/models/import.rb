class Import < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :user
  validates_associated :user
  validates_presence_of :s3_bucket
  validates_presence_of :s3_key
  validates_presence_of :s3_etag

  def csv_data
    return @csv_data if @csv_data
    s3_bucket = s3_service.buckets.find(self.s3_bucket)
    s3_object = s3_bucket.objects.find(self.s3_key) if s3_bucket
    @csv_data = s3_object.content if s3_object
  end

  def parser
    ImportParser.new(csv_data, ImportPerson) if csv_data
  end

  protected

  def s3_service
    access_key_id     = ENV["ACCESS_KEY_ID"]
    secret_access_key = ENV["SECRET_ACCESS_KEY"]

    S3::Service.new(:access_key_id => access_key_id, :secret_access_key => secret_access_key)
  end

end

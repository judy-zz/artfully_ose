class Import < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :user
  validates_associated :user
  validates_presence_of :s3_bucket
  validates_presence_of :s3_key
  validates_presence_of :s3_etag
  validates_presence_of :cached_data

  def headers
    cache_data!
    @headers ||= Marshal::load(File.read import_headers_tmp_filename)
  end

  def rows
    cache_data!
    @rows ||= Marshal::load(File.read import_rows_tmp_filename)
  end

  protected

  def cache_data!(force = false)
    FileUtils.mkdir_p(import_cache_path) unless File.directory?(import_cache_path)
    return if !force && File.file?(import_headers_tmp_filename) && File.file?(import_rows_tmp_filename)

    s3_bucket = s3_service.buckets.find(self.s3_bucket) if self.s3_bucket.present?
    s3_object = s3_bucket.objects.find(self.s3_key) if s3_bucket
    csv_data = s3_object.content if s3_object

    if csv_data.present?
      @headers = nil
      @rows = []

      csv_data.gsub! /\\"(?!,)/, '""' # Fix improperly escaped quotes.

      FasterCSV.parse(csv_data, :headers => false) do |row|
        if headers.nil?
          @headers = row.to_a
        else
          @rows << row.to_a
        end
      end

      File.open(import_headers_tmp_filename, "w:ASCII-8BIT") { |f| f.write Marshal::dump(@headers) }
      File.open(import_rows_tmp_filename, "w:ASCII-8BIT") { |f| f.write Marshal::dump(@rows) }
    end
  end

  def s3_service
    access_key_id     = ENV["ACCESS_KEY_ID"]
    secret_access_key = ENV["SECRET_ACCESS_KEY"]

    S3::Service.new(:access_key_id => access_key_id, :secret_access_key => secret_access_key)
  end

  def import_cache_path
    Rails.root.join("tmp", "imports", id.to_s)
  end

  def import_headers_tmp_filename
    import_cache_path.join "headers.dump"
  end

  def import_rows_tmp_filename
    import_cache_path.join "rows.dump"
  end

end

class Import < ActiveRecord::Base

  # Import status transitions:
  #   pending -> approved -> imported

  belongs_to :user

  validates_presence_of :user
  validates_associated :user
  validates_presence_of :s3_bucket
  validates_presence_of :s3_key
  validates_presence_of :s3_etag

  named_scope :pending, where(:status => "pending")
  named_scope :approved, where(:status => "approved")
  named_scope :importing, where(:status => "importing")
  named_scope :imported, where(:status => "imported")

  def headers
    cache_data!
    @headers ||= Marshal::load(File.read import_headers_tmp_filename)
  end

  def rows
    cache_data!
    @rows ||= Marshal::load(File.read import_rows_tmp_filename)
  end

  def perform
    self.importing!

    rows.each do |row|
      ip = ImportPerson.new(headers, row)
      person = AthenaPerson.new \
        :email           => ip.email,
        :first_name      => ip.first,
        :last_name       => ip.last,
        :company_name    => ip.company,
        :website         => ip.website,
        :organization_id => user.current_organization.id,
        :import_id       => self.id

      if !person.save
        p person.errors.full_messages
      else
        p person.id
      end
    end

    self.imported!
  end

  def destroy_people!
    AthenaPerson.find_by_import(self).each do |person|
      person.destroy
    end
  end

  def approve!
    self.update_attributes!(:status => "approved") if self.status == "pending"
  end

  def importing!
    self.update_attributes!(:status => "importing") if self.status == "approved"
  end

  def imported!
    self.update_attributes!(:status => "imported") if self.status == "importing"
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

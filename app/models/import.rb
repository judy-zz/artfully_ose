class Import < ActiveRecord::Base

  # Import status transitions:
  #   pending -> approved -> imported

  belongs_to :user
  has_many :import_errors, :dependent => :delete_all
  has_many :import_rows, :dependent => :delete_all

  validates_presence_of :user
  validates_associated :user
  validates_presence_of :s3_bucket
  validates_presence_of :s3_key
  validates_presence_of :s3_etag

  scope :pending, where(:status => "pending")
  scope :approved, where(:status => "approved")
  scope :importing, where(:status => "importing")
  scope :imported, where(:status => "imported")

  before_destroy :destroy_people!

  serialize :import_headers

  def headers
    cache_data!
    self.import_headers
  end

  def rows
    cache_data!
    self.import_rows
  end

  def perform
    self.importing!
    self.destroy_people!
    self.import_errors.delete_all
    self.import_rows.delete_all

    rows.each do |row|
      row = row.kind_of?(ImportRow) ? row.content : row
      ip = ImportPerson.new(headers, row)
      person = attach_person(ip)
      if person.save
        address = attach_address(person, ip)
        address.save
      else
        self.import_errors.create! :row_data => row, :error_message => person.errors.full_messages.join(", ")
      end
    end

    self.imported!
  end

  # Poll for people associated with this import in batches.
  def imported_people
    offset = 0
    limit  = 500

    loop do
      query  = { :importId => self.id, :_start => offset, :_limit => limit }
      people = AthenaPerson.find(:all, :params => query)
      people.each { |person| yield person }
      return if people.count < limit
    end
  end

  def destroy_people!
    imported_people { |person| person.destroy }
  end

  def approve!
    self.update_attributes!(:status => "approved")
  end

  def importing!
    self.update_attributes!(:status => "importing")
  end

  def imported!
    self.update_attributes!(:status => "imported")
  end

  protected

  def cache_data!(force = false)
    return unless self.import_rows.blank? || force

    csv_data =
      if File.file?(self.s3_key)
        File.read(self.s3_key)
      else
        s3_bucket = s3_service.buckets.find(self.s3_bucket) if self.s3_bucket.present?
        s3_object = s3_bucket.objects.find(self.s3_key) if s3_bucket
        s3_object.content if s3_object
      end

    raise "cannot load csv data" unless csv_data.present?

    self.import_headers = nil
    self.import_rows.delete_all

    csv_data.gsub!(/\\"(?!,)/, '""') # Fix improperly escaped quotes.

    FasterCSV.parse(csv_data, :headers => false) do |row|
      if self.import_headers.nil?
        self.import_headers = row.to_a
        self.save!
      else
        self.import_rows.create!(:content => row.to_a)
      end
    end
  end

  def s3_service
    access_key_id     = ENV["ACCESS_KEY_ID"]
    secret_access_key = ENV["SECRET_ACCESS_KEY"]

    S3::Service.new(:access_key_id => access_key_id, :secret_access_key => secret_access_key)
  end

  def attach_person(import_person)
    ip = import_person

    person = AthenaPerson.new \
      :email           => ip.email,
      :first_name      => ip.first,
      :last_name       => ip.last,
      :company_name    => ip.company,
      :website         => ip.website,
      :twitterHandle   => ip.twitter_username,
      :facebookUrl     => ip.facebook_page,
      :linkedInUrl     => ip.linkedin_page,
      :organization_id => user.current_organization.id,
      :import_id       => self.id

    ip.tags_list.each { |tag| person.tag! tag }

    person.phones << AthenaPerson::Phone.new(ip.phone1_type, ip.phone1_number) if ip.phone1_type.present? && ip.phone1_number.present?
    person.phones << AthenaPerson::Phone.new(ip.phone2_type, ip.phone2_number) if ip.phone2_type.present? && ip.phone2_number.present?
    person.phones << AthenaPerson::Phone.new(ip.phone3_type, ip.phone3_number) if ip.phone3_type.present? && ip.phone3_number.present?

    person
  end

  def attach_address(person, import_person)
    address = Address.new \
      :address1  => import_person.address1,
      :address2  => import_person.address2,
      :city      => import_person.city,
      :state     => import_person.state,
      :zip       => import_person.zip,
      :country   => import_person.country,
      :person_id => person.id
  end

end

class FA::User < FA::Base
  schema do
    attribute 'username',       :string
    attribute 'email',          :string
    attribute 'password',       :string
    attribute 'member_id',  :string
  end

  validates_presence_of :username,  :if => lambda { email.blank? }
  validates_presence_of :email,     :if => lambda { username.blank? }
  validates_presence_of :password

  def load(attrs, remove_root = false)
    hash_password(attrs) if attrs.has_key?(:password)
    super
  end

  def password=(passwd)
    passwd = Digest::MD5.hexdigest(passwd) unless passwd.nil?
    super(passwd)
  end

  def to_xml(options = {})
    exclude_username_from(options) unless email.blank?
    exclude_empty_from(options)
    super(options)
  end

  def authenticate
    return false unless valid?
    session = FA::Session.authenticate(self)
    load(session.user.attributes)
    session.authenticated?
  end

  private
    def hash_password(attrs)
      attrs[:password] = Digest::MD5.hexdigest(attrs[:password])
    end

    def exclude_username_from(options)
      options[:except] = (Array.wrap(options[:except]) << :username)
    end

    def exclude_empty_from(options)
      options[:except] = Array.wrap(options[:except])
      attributes.each do |key, value|
        options[:except] << key if value.blank?
      end
    end
end
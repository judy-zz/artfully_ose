class AthenaLock < AthenaResource::Base
  headers['X-ATHENA-Key'] = 'artful.ly'
  self.headers["User-agent"] = "artful.ly"

  self.site = Artfully::Application.config.tickets_site + "meta/"
  self.collection_name = 'locks'
  self.element_name = 'locks'

  validates_datetime :lock_expires, :after => lambda { DateTime.now }, :allow_blank => true

  schema do
    attribute 'id',             :integer
    attribute 'tickets',        :string
    attribute 'lock_expires',   :string
    attribute 'locked_by_api',  :string
    attribute 'locked_by_ip',   :string
    attribute 'status',         :string
  end

  def tickets
    @attributes['tickets'] ||= []
    @attributes['tickets']
  end

  def lock_expires=(expiration)
    @attributes['lock_expires'] = parse_lock_expires(expiration)
  end

  def lock_expires
    ensure_expiration_parsed
    @attributes['lock_expires']
  end

  def valid?
    ensure_expiration_parsed
    super
  end

  private
    def ensure_expiration_parsed
      @attributes['lock_expires'] = parse_lock_expires(@attributes['lock_expires'])
    end

    def parse_lock_expires(expiration)
      return expiration if expiration.nil? or expiration.instance_of? DateTime
      DateTime.parse(expiration)
    end
end

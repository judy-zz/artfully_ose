class AthenaLock < AthenaResource::Base
  headers['X-ATHENA-Key'] = 'artful.ly'
  self.headers["User-agent"] = "artful.ly"

  self.site = Artfully::Application.config.tickets_site
  self.prefix = "/tix/meta/"
  self.collection_name = 'locks'
  self.element_name = 'locks'

  validates_datetime :lock_expires, :after => lambda { DateTime.now }, :allow_blank => true

  schema do
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

  #TODO: Move this to macro at some point.
  class << self
    def collection_path(prefix_options = {}, query_options = nil)
      check_prefix_options(prefix_options)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}/.#{format.extension}#{query_string(query_options)}"
    end

    private

      def check_prefix_options(prefix_options)
        p_options = HashWithIndifferentAccess.new(prefix_options)
        prefix_parameters.each do |p|
          raise(MissingPrefixParam, "#{p} prefix_option is missing") if p_options[p].blank?
        end
      end
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

class AthenaLock < AthenaResource::Base
  headers['X-ATHENA-Key'] = 'artful.ly'

  self.site = Artfully::Application.config.tickets_site
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

  def initialize(*)
    super
    self.tickets ||= []
  end
end

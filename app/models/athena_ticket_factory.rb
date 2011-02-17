class AthenaTicketFactory < AthenaResource::Base
  self.site = Artfully::Application.config.tickets_site
  self.prefix = "/tix/meta/"
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'ticketfactory'
  self.collection_name = 'ticketfactory'

  schema do
    attribute 'event_id', :string
    attribute 'chart_id', :string
    attribute 'organization_id', :string
    attribute 'datetime', :string
  end

  def self.for_performance(performance)
    @factory = AthenaTicketFactory.new(performance.attributes)
    performance.build! if @factory.save
  end

end
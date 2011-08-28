class AthenaPerformance < AthenaResource::Base
  include ActiveResource::Transitions

  self.site = Artfully::Application.config.stage_site
  self.element_name = 'performances'
  self.collection_name = 'performances'

  validates_presence_of :datetime
  validates_datetime :datetime, :after => lambda { Time.now }

  COMP = 'Comp'

  schema do
    attribute 'id',               :integer
    attribute 'event_id',         :string
    attribute 'chart_id',         :string
    attribute 'datetime',         :string
    attribute 'state',            :string
    attribute 'organization_id',  :string
  end

  state_machine do
    state :pending
    state :built
    state :published
    state :unpublished

    event :build do
      transitions :from => :pending, :to => :built
    end

    event :publish do
      transitions :from => [ :built, :unpublished ], :to => :published
    end

    event :unpublish do
      transitions :from => :published, :to => :unpublished
    end
  end

  def organization
    @organization ||= Organization.find(organization_id)
  end

  def gross_potential
    @gross_potential ||= tickets.inject(0) { |sum, ticket| sum += ticket.price.to_i }
  end

  def gross_sales
    @gross_sales ||= tickets_sold.inject(0) { |sum, ticket| sum += ticket.price.to_i }
  end

  def tickets
    @tickets ||= find_tickets.sort_by { |ticket| ticket.price }
  end

  def tickets_sold
    @tickets_sold ||= tickets.select { |ticket| ticket.sold? }
  end

  def self.in_range(start, stop)
    start = "gt#{start.xmlschema}"
    stop = "lt#{stop.xmlschema}"
    instantiate_collection(query("datetime=#{start}&datetime=#{stop}"))
  end

  def self.next_datetime(performance)
    performance.nil? ? future(Time.now.beginning_of_day + 20.hours) : future(performance.datetime + 1.day)
  end

  def chart
    if chart_id.blank?
      return nil
    end
    @chart ||= AthenaChart.find(chart_id)
  end

  def chart=(chart)
    raise TypeError, "Expecting an AthenaChart" unless chart.kind_of? AthenaChart
    @chart, self.chart_id = chart, chart.id
  end

  def event
    @event ||= AthenaEvent.find(event_id)
  end

  def event=(event)
    raise TypeError, "Expecting an AthenaEvent" unless event.kind_of? AthenaEvent
    @event, self.event_id = event, event.id
  end

  def has_door_list?
    published? or unpublished?
  end

  def time_zone
    @time_zone ||= event.time_zone
  end

  def load(attributes)
    super(prepare_attr!(attributes))
  end

  def dup!
    copy = AthenaPerformance.new(self.attributes.reject { |key, value| key == 'id' || key == 'state' })
    copy.event = self.event
    copy.datetime = copy.datetime + 1.day
    copy
  end

  def add_performance_time_string
    attributes['performance_time'] = I18n.l( attributes['datetime'].in_time_zone(time_zone), :format => :long_with_day)
  end

  def glance
    @glance ||= AthenaGlanceReport.find(nil, :params => { :performanceId => self.id, :organizationId => self.organization_id })
  end

  #return accepted id's
  def bulk_comp_to(ids, buyer)
    tickets.select { |ticket| ids.include? ticket.id }.collect{ |ticket| ticket.id if ticket.comp_to(buyer) }.compact
  end

  def bulk_on_sale(ids)
    targets = (ids == :all) ? tickets : tickets.select { |t| ids.include? t.id }
    AthenaTicket.put_on_sale(targets)
  end

  def bulk_off_sale(ids)
    AthenaTicket.take_off_sale(tickets.select { |ticket| ids.include? ticket.id })
  end

  def bulk_delete(ids)
    tickets.select { |ticket| ids.include? ticket.id }.collect{ |ticket| ticket.id if ticket.destroy }.compact
  end

  def bulk_change_price(ids, price)
    tickets.select { |ticket| ids.include? ticket.id }.collect{ |ticket| ticket.id if ticket.change_price(price) }.compact
  end

  def settleables
    AthenaItem.find_by_performance_id(self.id).reject(&:modified?)
  end

  def live?
    built? or published? or unpublished?
  end

  def played?
    datetime < Time.now
  end

  def on_saleable_tickets
    tickets.select(&:on_saleable?)
  end

  def off_saleable_tickets
    tickets.select(&:off_saleable?)
  end

  def destroyable_tickets
    tickets.select(&:destroyable?)
  end

  def compable_tickets
    tickets.select(&:compable?)
  end
  
  def create_tickets
    tickets = ActiveSupport::JSON.decode(post(:createtickets).body)
    build!
  end

  private
    def self.future(date)
      return date if date > Time.now
      offset = date - date.beginning_of_day
      future(Time.now.beginning_of_day + offset + 1.day)
    end

    def find_tickets
      return [] if new_record?
      AthenaTicket.find(:all, :params => { :performanceId => "eq#{self.id}" })
    end

    def bulk_comp(ids)
      tickets.select { |ticket| ids.include? ticket.id }.collect{ |ticket| ticket.id unless ticket.comp_to }.compact
    end

    def prepare_attr!(attributes)
      attributes = attributes.with_indifferent_access
      if attributes["datetime"].kind_of?(String)
        Time.zone = time_zone
        offset = ActiveSupport::TimeZone.new(time_zone).formatted_offset
        dt = Time.zone.parse("#{attributes["datetime"]} #{offset}")
        dt -= 1.hour if dt.dst?
        attributes["datetime"] = dt
      end
      attributes
    end
end
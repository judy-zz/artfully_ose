class AthenaPerformance < AthenaResource::Base
  include ActiveResource::Transitions

  self.site = Artfully::Application.config.stage_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'performances'
  self.collection_name = 'performances'

  validates_presence_of :datetime

  PUT_ON_SALE = 'Put on Sale'
  TAKE_OFF_SALE = 'Take off Sale'
  DELETE = 'Delete'

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
    state :on_sale, :enter => :put_tickets_on_sale
    state :off_sale, :enter => :take_tickets_off_sale

    event :build do
      transitions :from => :pending, :to => :built
    end

    event :put_on_sale do
      transitions :from => [ :built, :off_sale ], :to => :on_sale
    end

    event :take_off_sale do
      transitions :from => :on_sale, :to => :off_sale
    end
  end

  def gross_potential
    @gross_potential ||= tickets.inject(0) { |sum, ticket| sum += ticket.price.to_i }
  end

  def gross_sales
    @gross_sales ||= tickets_sold.inject(0) { |sum, ticket| sum += ticket.price.to_i }
  end

  def tickets
    @tickets ||= AthenaTicket.find(:all, :params => { :performanceId => "eq#{self.id}" }).sort_by { |ticket| ticket.price }
  end

  def tickets_sold
    @tickets_sold ||= tickets.select { |ticket| ticket.sold? }
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
    on_sale? or off_sale?
  end

  def time_zone
    @time_zone ||= event.time_zone
  end

  def update_attributes(attributes)
    prepare_attr!(attributes)
    super
  end

  def dup!
    copy = AthenaPerformance.new(self.attributes.reject { |key, value| key == 'id' || key == 'state' })
    copy.datetime = copy.datetime + 1.day
    copy
  end

  def datetime
    Time.zone = time_zone
    attributes['datetime'] = Time.zone.parse(attributes['datetime']) if attributes['datetime'].is_a? String
    attributes['datetime']
  end

  def bulk_edit_tickets(ticket_ids, action)
    case action
      when PUT_ON_SALE
        bulk_on_sale(ticket_ids)
      when TAKE_OFF_SALE
        bulk_off_sale(ticket_ids)
      when DELETE
        bulk_delete(ticket_ids)
    end
  end

  private

    def take_tickets_off_sale
      tickets.map(&:off_sale!)
    end

    def put_tickets_on_sale
      tickets.map(&:on_sale!)
    end

    def bulk_on_sale(ids)
      tickets.select { |ticket| ids.include? ticket.id }.collect{ |ticket| ticket.id unless ticket.on_sale! }.compact
    end

    def bulk_off_sale(ids)
      tickets.select { |ticket| ids.include? ticket.id }.collect{ |ticket| ticket.id unless ticket.off_sale! }.compact
    end

    def bulk_delete(ids)
      tickets.select { |ticket| ids.include? ticket.id }.collect{ |ticket| ticket.id unless ticket.destroy }.compact
    end

    def prepare_attr!(attributes)
      unless attributes.blank? || attributes['datetime'].blank?
        temp_date_only = Date.strptime(attributes.delete('datetime'), "%m/%d/%Y")
        hour = attributes['datetime(4i)']
        minute = attributes['datetime(5i)']
        Time.zone = time_zone
        attributes['datetime'] = Time.zone.parse( temp_date_only.to_s ).change(:hour=>hour, :min=>minute)
      else
        attributes['datetime'] = nil
      end
      #we can erase the datetime fields that came with the time select
      clean_datetime_attributes attributes
    end

    def clean_datetime_attributes(attributes)
      attributes.delete('datetime(1i)')
      attributes.delete('datetime(2i)')
      attributes.delete('datetime(3i)')
      attributes.delete('datetime(4i)')
      attributes.delete('datetime(5i)')
    end
end
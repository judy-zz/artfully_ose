class AthenaPerformance < AthenaResource::Base
  include ActiveResource::Transitions

  self.site = Artfully::Application.config.stage_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'performances'
  self.collection_name = 'performances'

  validates_presence_of :datetime

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
    state :on_sale
    state :off_sale

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
    @tickets ||= find_tickets.sort_by { |ticket| ticket.price }
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
    copy.event = self.event
    copy.datetime = copy.datetime + 1.day
    copy
  end

  def add_performance_time_string
    attributes['performance_time'] = I18n.l( attributes['datetime'].in_time_zone(time_zone), :format => :long_with_day)
  end

  def datetime
    attributes['datetime'] = attributes['datetime'].in_time_zone(time_zone)
    return attributes['datetime']
  end

  def bulk_edit_tickets(ticket_ids, action)
    case action
      when COMP
        bulk_comp(ticket_ids)
    end
  end

  def glance
    @glance ||= AthenaGlanceReport.find(nil, :params => { :performanceId => self.id, :organizationId => self.organization_id })
  end

  #return accepted id's
  def bulk_comp_to(ids, buyer)
    tickets.select { |ticket| ids.include? ticket.id }.collect{ |ticket| ticket.id if ticket.comp_to(buyer) }.compact
  end

  def bulk_on_sale(ids)
    AthenaTicket.put_on_sale(tickets.select { |ticket| ids.include? ticket.id })
  end

  def bulk_off_sale(ids)
    AthenaTicket.take_off_sale(tickets.select { |ticket| ids.include? ticket.id })
  end

  def bulk_delete(ids)
    tickets.select { |ticket| ids.include? ticket.id }.collect{ |ticket| ticket.id if ticket.destroy }.compact
  end

  private
    def find_tickets
      return [] if new_record?
      AthenaTicket.find(:all, :params => { :performanceId => "eq#{self.id}" })
    end

    def bulk_comp(ids)
      tickets.select { |ticket| ids.include? ticket.id }.collect{ |ticket| ticket.id unless ticket.comp_to }.compact
    end

    def prepare_attr!(attributes)
      unless attributes.blank? || attributes['datetime'].blank?
        begin
          temp_date_only = Date.strptime(attributes.delete('datetime'), "%m/%d/%Y")
          hour = attributes['datetime(4i)']
          minute = attributes['datetime(5i)']
          Time.zone = time_zone
          attributes['datetime'] = Time.zone.parse( temp_date_only.to_s ).change(:hour=>hour, :min=>minute)
        rescue ArgumentError # handles cases where user enters non-date
          attributes['datetime'] = nil
        end
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
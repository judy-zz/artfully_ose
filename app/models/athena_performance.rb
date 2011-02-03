class AthenaPerformance < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'performances'
  self.collection_name = 'performances'

  validates_presence_of :datetime

  PUT_ON_SALE = 'PUT_ON_SALE'
  TAKE_OFF_SALE = 'TAKE_OFF_SALE'
  DELETE = 'DELETE'

  schema do
    attribute 'event_id', :string
    attribute 'chart_id', :string
    attribute 'producer_pid', :string
    attribute 'datetime', :string
    attribute 'tickets_created', :string
    attribute 'on_sale', :string
  end

  def gross_potential
    @gross_potential ||= tickets.inject(0) { |sum, ticket| sum += ticket.price.to_i }
  end

  def gross_sales
    @gross_sales ||= tickets_sold.inject(0) { |sum, ticket| sum += ticket.price.to_i }
  end

  def tickets_created
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(attributes['tickets_created'])
  end
  alias :tickets_created? :tickets_created

  def on_sale
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(attributes['on_sale'])
  end
  alias :on_sale? :on_sale

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

  #TODO: Move this into localization
  def day_of_week
    self.datetime.strftime("%A")
  end

  def formatted_performance_time
    self.datetime.strftime("%I:%M %p")
  end

  def formatted_performance_date
    self.datetime.strftime("%b, %d %Y")
  end

  def formatted_performance_date_for_input
    self.datetime.strftime("%m/%d/%Y")
  end

  def parsed_datetime
    if self.datetime.nil?
      nil
    else
      DateTime.parse(self.datetime)
    end
  end

  def update_attributes(attributes)
    prepare_attr!(attributes)
    super
  end

  def dup!
    copy = AthenaPerformance.new(self.attributes.reject { |key, value| key == 'id' || key == 'tickets_created' })
    copy.tickets_created = 'false'
    copy.on_sale = 'false'
    copy.datetime = copy.datetime + 1.day
    copy
  end

  def datetime
    attributes['datetime'] = DateTime.parse(attributes['datetime']) if attributes['datetime'].is_a? String
    attributes['datetime']
  end

  def take_off_sale
    tickets.map(&:off_sale!)
    attributes['on_sale'] = false
    save!
  end

  def put_on_sale
    tickets.map(&:on_sale!)
    attributes['on_sale'] = true
    save!
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
      #TODO: We need to set the correct time zone to whatever zone they're in
      unless attributes.blank? || attributes['datetime'].blank?
        temp_date_only = Date.parse(attributes.delete('datetime'))
        hour = attributes['datetime(4i)']
        minute = attributes['datetime(5i)']
        attributes['datetime'] = DateTime.parse("#{temp_date_only.year}-#{temp_date_only.month}-#{temp_date_only.day}T#{hour}:#{minute}:00-04:00")
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
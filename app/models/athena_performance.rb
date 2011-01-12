class AthenaPerformance < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'performances'
  self.collection_name = 'performances'

  schema do
    attribute 'event_id', :string
    attribute 'chart_id', :string
    attribute 'producer_id', :string
    attribute 'datetime', :string
    attribute 'tickets_created', :string
  end

  def tickets_created?
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(attributes['tickets_created'])
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
    copy.datetime = copy.datetime + 1.day
    copy
  end

  def datetime
    attributes['datetime'] = DateTime.parse(attributes['datetime']) if attributes['datetime'].is_a? String
    attributes['datetime']
  end

  private
    def prepare_attr!(attributes)
      #TODO: We need to set the correct time zone to whatever zone they're in
      unless attributes.blank?
        day = attributes.delete('datetime(3i)')
        month = attributes.delete('datetime(2i)')
        year = attributes.delete('datetime(1i)')
        hour = attributes.delete('datetime(4i)')
        minute = attributes.delete('datetime(5i)')
        attributes['datetime'] = DateTime.parse("#{year}-#{month}-#{day}T#{hour}:#{minute}:00-04:00")
      end
    end
end
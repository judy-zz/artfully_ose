class AthenaPerformance < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'performances'
  self.collection_name = 'performances'

  schema do
    attribute 'eventId', :string
    attribute 'chartId', :string
    attribute 'producerId', :string
    attribute 'datetime', :string
  end

  def chart
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

  def day_of_week
    DateTime.parse(self.datetime).strftime("%a")
  end

  def formatted_performance_time
    DateTime.parse(self.datetime).strftime("%I:%M %p")
  end
  
  def formatted_performance_date
    DateTime.parse(self.datetime).strftime("%b, %d %Y")
  end
  
  def update_attributes(attributes)
    prepare_attr!(attributes)
    super
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
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
    Date.parse(self.datetime).strftime("%a")
  end

  def formatted_performance_time
    Date.parse(self.datetime).strftime("%I:%M %p")
  end
  
  def formatted_performance_date
    Date.parse(self.datetime).strftime("%b, %d %Y")
  end
end
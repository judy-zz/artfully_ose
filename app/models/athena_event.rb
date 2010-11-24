class AthenaEvent < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.element_name = 'events'
  self.collection_name = 'events'

  schema do
    attribute 'name', :string
    attribute 'venue', :string
    attribute 'producer', :string
    attribute 'chart_id', :string
  end

  validates_presence_of :name, :venue, :producer

  def chart
    @chart ||= AthenaChart.find(chart_id)
  end

  def chart=(chart)
    raise TypeError, "Expecting an AthenaChart" unless chart.kind_of? AthenaChart
    @chart, self.chart_id = chart, chart.id
  end
end
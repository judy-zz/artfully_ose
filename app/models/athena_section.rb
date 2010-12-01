class AthenaSection < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'sections'
  self.collection_name = 'sections'
  
  schema do
    attribute 'name', :string
    attribute 'capacity', :integer
    attribute 'price', :integer
    attribute 'chartId', :string
  end

  def chart
    @chart ||= AthenaChart.find(chart_id)
  end

  def chart=(chart)
    raise TypeError, "Expecting an AthenaChart" unless chart.kind_of? AthenaChart
    @chart, self.chart_id = chart, chart.id
  end
end
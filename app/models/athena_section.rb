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
  
  #See note in athena_chart.rb
  #Note that this method does not copy any relations (chart_id)
  def deep_copy
    @new_section = AthenaSection.new
    @new_section.name = self.name
    @new_section.capacity = self.capacity 
    @new_section.price = self.price
    @new_section     
  end
end
class AthenaEvent < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'events'
  self.collection_name = 'events'

  schema do
    attribute 'name', :string
    attribute 'venue', :string
    attribute 'producer', :string
    attribute 'producer_pid', :string
    attribute 'chart_id', :string
  end

  validates_presence_of :name, :venue, :producer

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

  def performances
    @attributes['performances'] ||= AthenaPerformance.find(:all, :params => { :eventId => 'eq' + self.id })
  end

  def performances=(performances)
    raise TypeError, "Expecting an Array" unless performances.kind_of? Array
    @attributes['performances'] = performances
  end
end
class AthenaSection < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.element_name = 'sections'
  self.collection_name = 'sections'

  schema do
    attribute 'id',       :integer
    attribute 'name',     :string
    attribute 'capacity', :integer
    attribute 'price',    :integer
    attribute 'chart_id', :string
  end

  before_validation {capacity.strip!}

  validates :name, :presence => true

  validates :price, :presence => true,
                    :numericality => true

  validates :capacity,  :presence => true,
                        :numericality => { :less_than_or_equal_to => 1000 }

  def chart
    @chart ||= AthenaChart.find(chart_id)
  end

  def chart=(chart)
    raise TypeError, "Expecting an AthenaChart" unless chart.kind_of? AthenaChart
    @chart, self.chart_id = chart, chart.id
  end

  def dup!
    AthenaSection.new(self.attributes.reject { |key, value| key == 'id' })
  end
  
  def summarize(performance_id)
    tickets = AthenaTicket.find(:all, :params => {:performanceId => "eq#{performance_id}", :section => "eq#{name}"})
    summary = SectionSummary.for_tickets(tickets)
  end
  
  def create_tickets(performance_id, new_capacity)
    attributes['performance_id'] = performance_id
    attributes['capacity'] = new_capacity
    tickets = ActiveSupport::JSON.decode(post(:createtickets).body)
  end
end
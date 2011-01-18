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
  end

  validates_presence_of :name, :venue, :producer, :producer_pid

  def charts
    @attributes['charts'] ||= find_charts
  end

  def charts=(charts)
    raise TypeError, "Expecting an Array" unless charts.kind_of? Array
    @attributes['charts'] ||= charts
  end

  def performances
    @attributes['performances'] ||= find_performances
  end

  def performances=(performances)
    raise TypeError, "Expecting an Array" unless performances.kind_of? Array
    @attributes['performances'] = performances
  end

  def to_json(options = {})
    performances and charts and charts.each { |chart| chart.sections }
    super(options)
  end

  private
    def find_charts
      return [] if new_record?
      AthenaChart.find(:all, :params => { :eventId => "eq#{self.id}" })
    end

    def find_performances
      return [] if new_record?
      AthenaPerformance.find(:all, :params => { :eventId => "eq#{self.id}" })
    end
end
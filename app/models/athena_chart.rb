class AthenaChart < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'charts'
  self.collection_name = 'charts'

  validates_length_of :name, :maximum=>255

  schema do
    attribute 'name', :string
    attribute 'eventId', :string
    attribute 'performanceId', :string
    attribute 'isTemplate', :string
    attribute 'producerPid', :string
  end

  def sections
    @attributes['sections'] ||= find_sections
  end

  def sections=(sections)
    raise TypeError, "Expecting an Array" unless sections.kind_of? Array
    @attributes['sections'] = sections
  end

  def self.find_by_event(event)
    self.find(:all, :params => { :eventId => 'eq' + event.id })
  end

  def self.find_by_producer(producer_pid)
    self.find(:all, :params => { :producerPid => 'eq' + producer_pid })
  end

  def self.find_templates_by_producer(producer_pid)
    self.find(:all, :params => { :producerPid => 'eq' + producer_pid, :isTemplate => 'eqtrue' })
  end

  def dup!
    copy = AthenaChart.new(self.attributes.reject { |key, value| key == 'id' })
    copy.is_template = false
    copy.sections = self.sections.collect { |section| section.dup! }
    copy
  end

  def save
    super
    sections.each do |section|
      section.chart_id = self.id
      section.save
    end
  end

  def self.get_default_name(prefix)
    prefix + ', default chart'
  end

  def self.default_chart_for(event)
    raise TypeError, "Expecting an AthenaEvent" unless event.kind_of? AthenaEvent
    @chart = self.new
    @chart.name = self.get_default_name(event.name)
    @chart.event_id = event.id
    @chart
  end

  private
    def find_sections
      return [] if new_record?
      AthenaSection.find(:all, :params => { :chartId => "eq#{id}" })
    end
end
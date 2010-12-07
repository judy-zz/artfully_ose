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
    attribute 'producerPid', :string
  end
  
  def sections
    @sections ||= AthenaSection.find(:all, :params => { :chartId => 'eq' + self.id })
  end

  def sections=(sections)
    raise TypeError, "Expecting an Array" unless sections.kind_of? Array
    @sections = sections
  end
  
  def parent
    if !eventId.nil?
      @parent ||= AthenaEvent.find(:all, :params => { :chartId => 'eq' + self.id })
    elsif !performanceId.nil?
      @parent ||= AthenaPerformance.find(:all, :params => { :performanceId => 'eq' + self.id })
    end    
    @parent
  end
  
  def self.find_by_producer(producer_pid)
    self.find(:all, :params => { :producerPid => 'eq' + producer_pid })
  end
  
  #will copy this object, but not this object's id
  #will call deep_copy on the underlying sections attached ot this chart
  def deep_copy
    @new_chart = AthenaChart.new
    @new_chart.name = self.name
    @new_chart.producerPid = self.producer_pid
    @new_chart.sections = Array.new
    self.sections.each do |section|     
      #We really can use Object.dup here, but because of a bug in ATHENA we have to copy this by hand
      #https://www.pivotaltracker.com/story/show/6997445
      #essentially we're "forgetting" to serialize @section.id    
      @new_section = section.deep_copy
      @new_chart.sections << @new_section
    end
    @new_chart
  end
  
  def save
    super
    sections.each do |section|
      section.chart_id = self.id
      section.save
    end
  end
  
  def self.get_default_name(prefix)
    prefix + ',default chart'
  end
  
  def self.default_chart_for(event)
    raise TypeError, "Expecting an AthenaEvent" unless event.kind_of? AthenaEvent
    @chart = self.new
    @chart.name = self.get_default_name(event.name)
    @chart.event_id = event.id
    @chart
  end
end
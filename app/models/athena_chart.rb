class AthenaChart < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'charts'
  self.collection_name = 'charts'
  
  schema do
    attribute 'name', :string
    attribute 'eventId', :string
    attribute 'performanceId', :string
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
end
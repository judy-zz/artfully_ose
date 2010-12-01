class AthenaChart < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'charts'
  self.collection_name = 'charts'
  
  schema do
    attribute 'name', :string
  end
  
  def sections
    @sections ||= AthenaSection.find(:all, :params => { :chartId => 'eq' + self.id })
  end

  def sections=(sections)
    raise TypeError, "Expecting an Array" unless sections.kind_of? Array
    @sections = sections
  end
end
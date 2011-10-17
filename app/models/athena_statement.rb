class AthenaStatement < AthenaResource::Base
  self.site = Artfully::Application.config.reports_site
  self.element_name = "statement"
  self.collection_name = "statement"
  
  def self.for_performance(show_id, organization_id)
    self.find(nil, :params => { :performanceId => show_id, :organizationId => organization_id})
  end
end
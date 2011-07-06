class AthenaStatement < AthenaResource::Base
  self.site = Artfully::Application.config.reports_site
  self.element_name = "statement"
  self.collection_name = "statement"
  
  def self.for_performance(performance_id, organization_id)
    self.find(nil, :params => { :performanceId => performance_id, :organizationId => organization_id})
  end
end
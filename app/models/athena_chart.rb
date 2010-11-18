class AthenaChart < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.element_name = 'charts'
  self.collection_name = 'charts'
  
  schema do
    attribute 'capacity', :integer
  end
end
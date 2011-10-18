class AthenaGlanceReport < AthenaResource::Base
  self.site = Artfully::Application.config.reports_site
  self.element_name = "glance"
  self.collection_name = "glance"

  schema do
    attribute 'shows_on_sale', :integer
  end
end

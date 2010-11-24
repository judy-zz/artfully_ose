class AthenaPerson < AthenaResource::Base
  self.site = Artfully::Application.config.people_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'people'
  self.collection_name = 'people'

  schema do
    attribute 'email', :string
  end

  validates_presence_of :email
end
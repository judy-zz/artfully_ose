class AthenaEventAction < AthenaAction

  self.site = Artfully::Application.config.people_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'actions'
  self.collection_name = 'actions'

  def initialize(attributes = {})
    super(attributes)
    @attributes['action_type'] = "Go"
  end
  
end
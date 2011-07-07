class AthenaServiceAction < AthenaAction
  self.site = Artfully::Application.config.people_site
  self.element_name = 'actions'
  self.collection_name = 'actions'

  def initialize(attributes = {})
    super(attributes)
    @attributes['action_type'] = "Do"
  end

end
class AthenaPurchaseAction < AthenaAction

  self.site = Artfully::Application.config.people_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'actions'
  self.collection_name = 'actions'

  def initialize(attributes = {})
    super(attributes)
    @attributes['action_type'] = "Get"
  end

  private
    def find_subject
      begin
        AthenaOrder.find(self.subject_id)
      rescue ActiveResource::ResourceNotFound
        update_attribute(:subject_id, nil)
        return nil
      end
    end

end
class AthenaDonationAction < AthenaAction
  self.site = Artfully::Application.config.people_site
  self.element_name = 'actions'
  self.collection_name = 'actions'

  def initialize(attributes = {})
    super(attributes)
    @attributes['action_type'] = "Give"
  end

  def set_params(params, person, organization)
    self.dollar_amount = params[:dollar_amount]
    super(params, person, organization)
  end

  private
    def find_subject
      Donation.find(self.subject_id)
    end
end
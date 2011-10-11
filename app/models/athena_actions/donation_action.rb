class DonationAction < Action
  def initialize(attributes = {})
    super(attributes.merge(:action_type => "Give"))
  end

  def set_params(params, person, organization)
    params ||= {}
    self.dollar_amount = params[:dollar_amount]
    super(params, person, organization)
  end

  private
    def find_subject
      # raise ApplicationError
    end
end
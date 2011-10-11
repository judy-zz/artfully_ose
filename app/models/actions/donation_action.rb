class DonationAction < Action
  def action_type
    "Give"
  end

  def set_params(params, person, organization)
    params ||= {}
    self.dollar_amount = params[:dollar_amount]
    super(params, person, organization)
  end
end
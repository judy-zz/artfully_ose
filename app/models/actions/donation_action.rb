class DonationAction < Action
  def action_type
    "Give"
  end

  def set_params(params, person, organization)
    params ||= {}
    self.dollar_amount = params[:dollar_amount]
    super(params, person, organization)
  end

  def subject
    @subject ||= Donation.find(subject_id)
  end

  def subject=(sub)
    self.subject_id = sub.id
    @subject = sub
  end
end
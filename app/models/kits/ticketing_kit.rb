class TicketingKit < Kit
  acts_as_kit :with_approval => true do
    activate :unless => :no_owner?
    approve :unless => :no_bank_account?

    when_active do |organization|
      organization.can :access, :paid_ticketing
    end
  end
  
  def friendly_name
    "Paid Event Ticketing"
  end
  
  def pitch
    "Sell tickets"
  end

  def no_owner?
    errors.add(:requirements, "You need to be part of an organization to activate this kit.") if organization.owner.nil?
    organization.owner.nil?
  end

  def no_bank_account?
    errors.add(:requirements, "Your organization needs bank account information first.") if organization.bank_account.nil?
    organization.bank_account.nil?
  end

  def on_pending
    AdminMailer.ticketing_kit_notification(self).deliver
  end

end
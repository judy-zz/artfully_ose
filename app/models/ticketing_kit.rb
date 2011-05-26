class TicketingKit < Kit
  acts_as_kit :with_approval => true do
    activate_kit :unless => :no_cards?
    activate_kit :unless => :no_owner?

    when_active do |organization|
      organization.can :access, :paid_ticketing
    end
  end

  def no_cards?
    errors.add(:requirements, "You need at least one credit card to activate this kit.") if organization.owner.credit_cards.empty?
    organization.owner.credit_cards.empty?
  end

  def no_owner?
    errors.add(:requirements, "You need to be part of an organization to activate this kit.") if organization.owner.nil?
    organization.owner.nil?
  end
end
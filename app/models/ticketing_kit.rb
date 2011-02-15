class TicketingKit < Kit
  acts_as_kit :with_approval => false do
    activate_kit :unless => :no_cards?
    activate_kit :unless => :no_organization?

    grant :role => :producer, :by => lambda { |kit| kit.user.add_role :producer }
  end

  def no_cards?
    errors.add(:requirements, "You need at least one credit card to activate this kit") if user.credit_cards.empty?
    user.credit_cards.empty?
  end

  def no_organization?
    errors.add(:requirements, "You need to be part of an organization to activate this kit") if user.organizations.empty?
    user.organizations.empty?
  end
end
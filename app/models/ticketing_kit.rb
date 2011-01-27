class TicketingKit < Kit
  acts_as_kit :for => User, :with_approval => false do
    activate_kit :unless => lambda { |kit| kit.user.credit_cards.empty? }
    activate_kit :unless => lambda { |kit| kit.user.organization.nil? }
    grant :role => :producer, :by => lambda { |kit| kit.user.add_role :producer }
  end
end
class TicketingKit < ActiveRecord::Base
  # acts_as_kit :for => User, :with_approval => false
  include ActiveRecord::Transitions
  belongs_to :user

  state_machine do
    state :active
    state :cancelled

    event :cancel do
      transitions :from => [:active, :rejected ], :to => :cancelled
    end
  end
end
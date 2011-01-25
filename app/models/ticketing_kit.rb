class TicketingKit < ActiveRecord::Base
  # acts_as_kit :for => User, :with_approval => false
  include ActiveRecord::Transitions
  belongs_to :user

  validates_presence_of :user

  state_machine do
    state :new
    state :active
    state :cancelled

    event :activate do
      transitions :from => :new, :to => :active, :guard => :activatable?
    end

    event :cancel do
      transitions :from => [:active, :rejected ], :to => :cancelled
    end
  end

  def activatable?
    new? and (!!user) and (!user.credit_cards.empty?)
  end

end
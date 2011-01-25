class TicketingKit < ActiveRecord::Base
  # acts_as_kit :for => User, :with_approval => false
  include ActiveRecord::Transitions
  belongs_to :user

  validates_presence_of :user

  state_machine do
    state :new
    state :activated, :enter => :on_activate
    state :cancelled

    event :activate do
      transitions :from => :new, :to => :activated, :guard => :activatable?
    end

    event :cancel do
      transitions :from => [:activated, :rejected ], :to => :cancelled
    end
  end

  def activatable?
    new? and (!!user) and (!user.credit_cards.empty?)
  end

  protected
    def on_activate
      user.add_role :producer
    end
end
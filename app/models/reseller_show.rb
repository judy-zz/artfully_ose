class ResellerShow < ActiveRecord::Base

  belongs_to :reseller_event
  belongs_to :event, :class_name => "ResellerEvent", :foreign_key => "reseller_event_id"
  belongs_to :reseller_profile
  belongs_to :profile, :class_name => "ResellerProfile", :foreign_key => "reseller_profile_id"

  set_watch_for :datetime, :local_to => :reseller_event
  set_watch_for :datetime, :local_to => :event

  include ActiveRecord::Transitions
  state_machine do
    state :pending
    state :published
    state :unpublished

    event(:publish)   { transitions :from => [ :built, :unpublished ], :to => :published }
    event(:unpublish) { transitions :from => :published, :to => :unpublished }
  end

end

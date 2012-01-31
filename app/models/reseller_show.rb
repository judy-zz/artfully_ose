class ResellerShow < ActiveRecord::Base

  belongs_to :reseller_event
  belongs_to :event, :class_name => "ResellerEvent", :foreign_key => "reseller_event_id"
  belongs_to :reseller_profile
  belongs_to :profile, :class_name => "ResellerProfile", :foreign_key => "reseller_profile_id"
  delegate :organization, :to => :reseller_profile

  set_watch_for :datetime, :local_to => :reseller_event
  set_watch_for :datetime, :local_to => :event

  include ActiveRecord::Transitions
  state_machine do
    state :unpublished
    state :published

    event(:publish)   { transitions :from => :unpublished, :to => :published }
    event(:unpublish) { transitions :from => :published, :to => :unpublished }
  end

  def played?
    datetime < Time.now
  end

  def show_time
    I18n.l(datetime_local_to_event, :format => :long_with_day)
  end

  def as_json(options={})
    {
      "id"        => id,
      "state"     => state,
      "show_time" => show_time,
      "datetime"  => datetime
    }
  end

end

class Action < ActiveRecord::Base
  belongs_to :person
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  belongs_to :organization

  validates_presence_of :occurred_at
  validates_presence_of :person_id

  set_watch_for :occurred_at, :local_to => :organization
  #
  # Action types: give, go, do, get, join, hear
  #

  GIVE_TYPES = [ "Donation (Cash)", "Donation (Check)", "Donation (In-Kind)" ].freeze

  def self.create_of_type(type)
    case type
      when "hear" then HearAction.new
      when "give" then GiveAction.new
    end
  end

  def set_params(params, person, curr_user)
    params ||= {}
    #params = prepare_datetime(params,curr_user.current_organization.time_zone)
    self.creator_id = curr_user.id
    self.organization_id = curr_user.current_organization.id

    self.occurred_at = params[:occurred_at]
    self.subtype = params[:subtype]
    self.details = params[:details]

    self.person = person
    self.subject_id = person.id
  end

  def unstarred?
    !starred?
  end

  def hear_action_subtypes
    [ "Email (sent)",
      "Email (received)",
      "Phone (initiated)",
      "Phone (received)",
      "Postal (sent)",
      "Postal (received)",
      "Meeting",
      "Twitter",
      "Facebook",
      "Blog",
      "Press" ]
  end

  def give_action_subtypes
    GIVE_TYPES
  end
end

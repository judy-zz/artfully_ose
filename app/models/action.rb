class Action < ActiveRecord::Base
  belongs_to :person
  belongs_to :organization

  validates_presence_of :occurred_at
  validates_presence_of :person_id

  #
  # Action types: give, go, do, get, join, hear
  #

  GIVE_TYPES = [ "Donation (Cash)", "Donation (Check)", "Donation (In-Kind)" ].freeze

  def self.create_of_type(type)
    case type
      when "hear" then CommunicationAction.new
      when "give" then DonationAction.new
    end
  end

  def set_params(params, person, curr_user)
    params ||= {}
    params = prepare_datetime(params,curr_user.current_organization.time_zone)
    self.creator_id = curr_user.id
    self.organization_id = curr_user.current_organization.id

    self.occurred_at = params[:occurred_at]
    self.action_subtype = params[:action_subtype]
    self.details = params[:details]

    self.person = person
    self.subject_id = person.id

    self.timestamp = DateTime.now
  end

  def starred?
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include? starred
  end

  def unstarred?
    !starred?
  end

  def subject
    raise ApplicationError
  end

  def self.find_by_person_and_organization(person, organization)
    find(:all, :params => { :personId => "eq#{person.id}", :organizationId => "eq#{organization.id}"})
  end

  def subject=(subject)
    raise ApplicationError
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

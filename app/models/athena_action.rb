class AthenaAction < AthenaResource::Base
  self.site = Artfully::Application.config.people_site
  self.element_name = 'actions'
  self.collection_name = 'actions'

  validates_presence_of :occurred_at
  validates_presence_of :person_id

  #
  # Action types: give, go, do, get, join, hear
  #

  GIVE_TYPES = [ "Donation (Cash)", "Donation (Check)", "Donation (In-Kind)" ].freeze

  schema do
    attribute 'organization_id',    :string
    attribute 'person_id',          :string
    attribute 'subject_id',         :string
    attribute 'creator_id',         :string
    attribute 'action_type',        :string
    attribute 'action_subtype',     :string
    attribute 'occurred_at',        :string
    attribute 'details',            :string
    attribute 'timestamp',          :string
    attribute 'starred',            :string
    attribute 'dollar_amount',      :string
  end

  def action_type(); @attributes['action_type']; end
  def action_type=(action_type); ;end

  def self.create_of_type(type)
    case type
      when "hear" then AthenaCommunicationAction.new
      when "give" then AthenaDonationAction.new
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

  def person
    @person ||= find_person
  end

  def person=(person)
    if person.nil?
      @person = person_id = person
      return
    end

    raise TypeError, "Expecting an AthenaPerson" unless person.kind_of? AthenaPerson
    @person, self.person_id = person, person.id
  end

  def subject
    @subject ||= find_subject
  end

  def self.find_by_person_and_organization(person, organization)
    find(:all, :params => { :personId => "eq#{person.id}", :organizationId => "eq#{organization.id}"})
  end

  def subject=(subject)
    return if subject.nil? or subject.id.nil?
    @subject, self.subject_id = subject, subject.id
  end

  #TODO: push up into AthenaResource
  def timestamp
    attributes['timestamp'] = DateTime.parse(attributes['timestamp']) if attributes['timestamp'].is_a? String
    attributes['timestamp']
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

  def prepare_datetime(attributes, tz)
    attributes = attributes.with_indifferent_access
    if attributes["occurred_at"].kind_of?(String)
      Time.zone = tz
      attributes["occurred_at"] = Time.zone.parse(attributes["occurred_at"])
    end
    attributes
  end

  private


    def find_person
      return if self.person_id.nil?

      begin
        AthenaPerson.find(self.person_id)
      rescue ActiveResource::ResourceNotFound
        update_attribute(:person_id, nil)
        return nil
      end
    end
end

class AthenaAction < AthenaResource::Base
  self.site = Artfully::Application.config.people_site
  self.element_name = 'actions'
  self.collection_name = 'actions'

  validates_presence_of :occurred_at
  validates_presence_of :person_id, :subject_id

  #
  # Action types: give, go, do, get, join, hear
  #

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
    if "HEAR" == type
      action = AthenaCommunicationAction.new
    elsif "GIVE" == type
      action = AthenaDonationAction.new
    end
    action
  end

  def set_params(params, person, curr_user)
    self.prepare_datetime(params, curr_user.current_organization.time_zone)
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
    [ "Donation (Cash)",
      "Donation (Check)",
      "Donation (In-Kind)" ]
  end

  def prepare_datetime(attributes, tz)
    unless attributes.blank? || attributes['occurred_at'].blank?
      begin
        temp_date_only = Date.strptime(attributes.delete('occurred_at'), "%m/%d/%Y")
        hour = attributes['occurred_at(4i)']
        minute = attributes['occurred_at(5i)']
        Time.zone = tz
        attributes['occurred_at'] = Time.zone.parse( temp_date_only.to_s ).change(:hour=>hour, :min=>minute)
      rescue ArgumentError # handles cases where user enters non-date
        attributes['occurred_at'] = nil
      end
    else
      attributes['occurred_at'] = nil
    end
    #we can erase the datetime fields that came with the time select
    clean_datetime_attributes attributes
  end

  private

    def clean_datetime_attributes(attributes)
      attributes.delete('occurred_at(1i)')
      attributes.delete('occurred_at(2i)')
      attributes.delete('occurred_at(3i)')
      attributes.delete('occurred_at(4i)')
      attributes.delete('occurred_at(5i)')
    end

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

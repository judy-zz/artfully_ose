class AthenaAction < AthenaResource::Base

  self.site = Artfully::Application.config.people_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'actions'
  self.collection_name = 'actions'

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
    attribute 'action_time',        :string
    attribute 'details',            :string
    attribute 'timestamp',          :string
    attribute 'starred',            :string
  end

  def action_type(); @attributes['action_type']; end
  def action_type=(action_type); ;end

  validates_presence_of :person_id, :subject_id

  def initialize(attributes = {})
    super(attributes)
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
    ["Email", "Phone Call", "Text"]
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

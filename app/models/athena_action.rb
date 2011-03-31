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
    attribute 'action_type',        :string
    attribute 'details',            :string
    attribute 'datetime',           :string
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
  def datetime
    attributes['datetime'] = DateTime.parse(attributes['datetime']) if attributes['datetime'].is_a? String
    attributes['datetime']
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

    def find_subject
      begin
        AthenaOrder.find(self.subject_id)
      rescue ActiveResource::ResourceNotFound
        update_attribute(:subject_id, nil)
        return nil
      end
    end
end

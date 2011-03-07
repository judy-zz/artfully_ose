class AthenaPurchaseAction < AthenaResource::Base

  self.site = Artfully::Application.config.people_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'actions'
  self.collection_name = 'actions'

  schema do
    attribute 'person_id',  :string
    attribute 'subject_id', :string
    attribute 'type',       :string
  end

  def type();@attributes['type'];end
  def type=(type);;end

  validates_presence_of :person_id, :subject_id

  def initialize(attributes = {})
    super(attributes)
    @attributes['type'] = "purchase"
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

  def subject=(subject)
    return if subject.nil? or subject.id.nil?
    @subject, self.subject_id = subject, subject.id
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
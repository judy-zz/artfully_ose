class AthenaRelationship < AthenaResource::Base
  self.site = Artfully::Application.config.people_site
  self.element_name = 'relationships'
  self.collection_name = 'relationships'

  schema do
    attribute 'id',                 :integer
    attribute 'left_side_id',       :string
    attribute 'relationship_type',  :string
    attribute 'right_side_id',      :string
    attribute 'inverse_type',       :string
    attribute 'starred',            :string
  end

  validates_presence_of :left_side_id, :right_side_id
  validates_presence_of :relationship_type, :inverse_type

  def subject
    @subject ||= find_subject
  end

  def starred?
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include? starred
  end

  def unstarred?
    !starred?
  end

  def subject=(subject)
    raise TypeError, "Expecting an AthenaPerson" unless subject.kind_of? AthenaPerson
    @subject, self.left_side_id = subject, subject.id
  end

  def object
    @object ||= find_object
  end

  def object=(object)
    raise TypeError, "Expecting an AthenaPerson" unless subject.kind_of? AthenaPerson
    @object, self.right_side_id = object, object.id
  end

  def self.find_by_person(person_or_id)
    id = person_or_id.kind_of?(AthenaPerson)? person_or_id.id : person_or_id
    return if id.nil?

    #TODO: This is a hack because the relationship helper listens at (COMPONENT_NAME)/meta/relationships
    # but we need to POST to /relationships to create a new object
    self.collection_name = 'meta/relationships'
    relationships = find(:all, :from => "people/#{id}".to_sym)
    self.collection_name = 'relationships'
    relationships
  end

  #convenience methods for normalizing the target of this relationship
  #since the person may be on the left of right

  #returns an AthenaPerson or nil if person is not a member of this relationship
  def person(person)
    id = person.kind_of?(AthenaPerson)? person.id : person
    if left_side_id == id.to_s
      AthenaPerson.find(right_side_id)
    elsif right_side_id == id.to_s
      AthenaPerson.find(left_side_id)
    else
      nil
    end
  end

  #Returns a string describing the relationship or '' if person is not a member of this relationship
  def relationship(person)
    id = person.kind_of?(AthenaPerson)? person.id : person
    if left_side_id == id.to_s
      relationship_type
    elsif right_side_id == id.to_s
      inverse_type
    else
      ''
    end
  end

  private
    def find_subject
      find_person(left_side_id)
    end

    def find_object
      find_person(right_side_id)
    end

    def find_person(id)
      begin
        AthenaPerson.find(id)
      rescue ActiveResource::ResourceNotFound
        return nil
      end
    end
end
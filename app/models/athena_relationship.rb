class AthenaRelationship < AthenaResource::Base
  self.headers["User-agent"] = "artful.ly"
  self.site = Artfully::Application.config.people_site + "meta/"

  self.element_name = 'relationships'
  self.collection_name = 'relationships'

  schema do
    attribute 'id',                 :integer
    attribute 'left_side_id',       :string
    attribute 'right_side_id',      :string
    attribute 'relationship_type',  :string
    attribute 'inverse_type',       :string
  end

  validates_presence_of :left_side_id, :right_side_id
  validates_presence_of :relationship_type, :inverse_type

  def subject
    @subject ||= find_subject
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
    find(:all, :from => "people/#{id}".to_sym)
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
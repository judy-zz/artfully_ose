class ListSegment < AthenaResource::Base
  self.site = Artfully::Application.config.people_site
  self.element_name = 'list_segments'
  self.collection_name = 'list_segments'

  schema do
    attribute 'name',             :string
    attribute 'people_ids',       :string
    attribute 'organization_id',  :string
  end

  validates :organization_id, :presence => true
  validates :name, :presence => true, :length => { :maximum => 128 }
  validate :same_organization

  def people_ids
    attributes['people_ids'] = Array.wrap(attributes['people_ids']) unless attributes['people_ids'].kind_of? Array
    attributes['people_ids']
  end

  def people
    @people ||= find_people
  end

  def people=(ppl)
    @people, self.people_ids = ppl, Array.wrap(ppl).collect(&:id)
  end

  def organization
    @organization ||= Organization.find(organization_id)
  end

  def organization=(org)
    raise TypeError, "Expecting an Organization" unless org.kind_of? Organization
    @organization, self.organization_id = org, org.id
  end

  def length
    people_ids.length
  end

  private

  def find_people
    people_ids.collect { |person_id| AthenaPerson.find(person_id) }
  end

  def same_organization
    errors.add(:base, "Invalid user selection") unless people.all? { |person| person.organization_id == self.organization_id }
  end
end
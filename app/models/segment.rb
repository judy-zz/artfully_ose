class Segment < AthenaResource::Base
  self.site = Artfully::Application.config.people_site

  schema do
    attribute 'name',             :string
    attribute 'organization_id',  :string
    attribute 'terms',            :string
  end

  validates :organization_id, :presence => true
  validates :name, :presence => true, :length => { :maximum => 128 }

  def organization
    @organization ||= Organization.find(organization_id)
  end

  def organization=(org)
    raise TypeError, "Expecting an Organization" unless org.kind_of? Organization
    @organization, self.organization_id = org, org.id.to_s
  end

  def people
    @people ||= Person.search_index(terms, organization)
  end

  def length
    people.size
  end
end
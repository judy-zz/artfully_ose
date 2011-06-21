class AthenaPerson < AthenaResource::Base
  self.site = Artfully::Application.config.people_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'people'
  self.collection_name = 'people'

  validates_presence_of :person_info
  validates_presence_of :organization_id

  schema do
    attribute 'id',             :integer
    attribute 'email',          :string
    attribute 'first_name',     :string
    attribute 'last_name',      :string
    attribute 'organization_id',:integer
  end

  def user
    @user ||= User.find_by_athena_id(id)
  end

  #TODO: This isn't actually recent, but that's an Athena problem, not an artfully problem
  def self.recent(organization)
    search_index(nil, organization)
  end

  def self.find_by_email_and_organization(email, organization)
    find(:first, :params => { :email => "eq#{email}", :organizationId => "eq#{organization.id}"})
  end

  def self.find_by_organization(organization)
    find_by_organization_id(organization.id)
  end

  def self.find_or_new_by_email(email, organization)
    return if email.blank?
    find_by_email_and_organization(email, organization) || new(:email => email)
  end

  def organization
    @organization ||= Organization.find(organization_id)
  end

  #Sort of a verbose Java-like pattern, but it makes the views very readable
  def actions
    @actions ||= AthenaAction.find_by_person_and_organization(self, organization)
  end

  def starred_actions
    actions.select { |action| action.starred? }
  end

  def unstarred_actions
    actions.select { |action| action.unstarred? }
  end

  def relationships
    @relationships ||= AthenaRelationship.find_by_person(self)
  end

  def starred_relationships
    relationships.select { |relationship| relationship.starred? }
  end

  def unstarred_relationships
    relationships.select { |relationship| relationship.unstarred? }
  end

  def organization=(org)
    raise TypeError, "Expecting an Organization" unless org.kind_of? Organization
    org.save unless org.persisted?
    @organization, self.organization_id = org, org.id
  end

  def person_info
    email or first_name or last_name
  end

end
class AthenaPerson < AthenaResource::Base
  self.site = Artfully::Application.config.people_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'people'
  self.collection_name = 'people'

  validates_presence_of :email
  validates_presence_of :first_name, :last_name
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

  def self.find_by_email_and_organization(email, organization)
    find(:all, :params => { :email => "eq#{email}", :organizationId => "eq#{organization.id}"})
  end

  def organization
    @organization ||= Organization.find(organization_id)
  end

  def organization=(org)
    raise TypeError, "Expecting an Organization" unless org.kind_of? Organization
    org.save unless org.persisted?
    @organization, self.organization_id = org, org.id
  end
end
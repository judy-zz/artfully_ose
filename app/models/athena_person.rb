class AthenaPerson < AthenaResource::Base
  self.site = Artfully::Application.config.people_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'people'
  self.collection_name = 'people'

  schema do
    attribute 'email', :string
  end

  def user
    @user ||= User.find_by_athena_id(id)
  end

  validates_presence_of :email
end
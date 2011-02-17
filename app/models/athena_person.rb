class AthenaPerson < AthenaResource::Base
  self.site = Artfully::Application.config.people_site
  self.headers["User-agent"] = "artful.ly"
  self.element_name = 'people'
  self.collection_name = 'people'

  validates_presence_of :email

  schema do
    attribute 'id', :integer
    attribute 'email', :string
  end

  def user
    @user ||= User.find_by_athena_id(id)
  end

  def self.find_by_email(email)
    find(:all, :params => { :email => "eq#{email}"})
  end
end
class FA::Project < FA::Base
 self.element_name = "project"

  schema do
    attribute 'id',  :string
    attribute 'member_id',  :string
    attribute 'name',  :string
    attribute 'category',  :string
    attribute 'profile',  :string
    attribute 'website',  :string
    attribute 'applied_on',  :string
    attribute 'status',  :string
  end

  def self.find_active_by_member_id(member_id)
    response = self.connection.get("/fs/projects.xml?member_id=#{member_id}&status=Active")
    fs_project = FA::Project.new(format.decode(response.body)['fs_project'])
    fs_project
  end
end
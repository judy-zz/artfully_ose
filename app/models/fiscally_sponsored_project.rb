class FiscallySponsoredProject < ActiveRecord::Base
  belongs_to :organization

  def refresh
    with_remote_project do |project|
      update_attributes(self.class.attributes_from(project))
    end
  end

  def active?
    status == "Active"
  end

  def inactive?
    !active?
  end

  private

  def remote_project
    FA::Project.find_by_member_id(fa_member_id)
  end

  def self.attributes_from(project)
    { :fs_project_id => project.id,
      :fa_member_id  => project.member_id,
      :name          => project.name,
      :category      => project.category,
      :profile       => project.profile,
      :website       => project.website,
      :applied_on    => DateTime.parse(project.applied_on),
      :status        => project.status }
  end

  def with_remote_project(&block)
    begin
      block.call(remote_project)
    rescue ActiveResource::ResourceNotFound
      logger.debug("No FAFS project found for member id #{fa_member_id}")
    end
  end
end
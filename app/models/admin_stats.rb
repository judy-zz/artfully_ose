class AdminStats
  #Fully intend to move this into ActiveRecord and update it hourly with cron  
  attr_accessor :users, :logged_in_more_than_once, :organizations, :fa_connected_orgs, :active_fafs_projects
  
  def self.load
    AdminStats.new.tap do |stats|
      stats.users = User.count
      stats.logged_in_more_than_once = User.logged_in_more_than_once.count
      stats.organizations = Organization.count
      stats.fa_connected_orgs = Organization.linked_to_fa.count
      stats.active_fafs_projects = FiscallySponsoredProject.active.count
    end    
  end
end
class AdminStats < ActiveRecord::Base  
  
  scope :latest, order("updated_at DESC").limit(1)
  
  def self.most_recent
    self.latest.first
  end
  
  #This method is called by the job and reports the up-to-the-second stats.  
  #For the cron'd stats, call the :recent 
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
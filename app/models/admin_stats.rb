class AdminStats < ActiveRecord::Base

  scope :latest, order("updated_at DESC").limit(1)

  def self.most_recent
    self.latest.first
  end

  #This method is called by the job and reports the up-to-the-second stats.
  #For the cron'd stats, call the :recent
  def self.load
    new([user_stats, organization_stats, kit_stats, ticket_stats, donation_stats].reduce(&:merge))
  end

  private

  def self.user_stats
    {
      :users                    => User.count,
      :logged_in_more_than_once => User.logged_in_more_than_once.count
    }
  end

  def self.organization_stats
    {
      :organizations            => Organization.count,
      :fa_connected_orgs        => Organization.linked_to_fa.count,
      :active_fafs_projects     => FiscallySponsoredProject.active.count,
    }
  end

  def self.kit_stats
    {
      :ticketing_kits => TicketingKit.where(:state => :activated).count,
      :donation_kits  => RegularDonationKit.where(:state => :activated).count + SponsoredDonationKit.where(:state => :activated).count
    }
  end

  def self.ticket_stats
    {
      :tickets      => 0,
      :tickets_sold => Ticket.find_by_state("sold").count
    }
  end

  def self.donation_stats
    donations = Item.find(:all, :params => { :productType => "Donation", :state => "in(settled, purchased)"})
    {
      :donations => donations.count,
      :fafs_donations => donations.select{ |d| d.fs_project_id.present? }.count
    }
  end
end
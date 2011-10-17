class AddStatsToAdminStats < ActiveRecord::Migration
  def self.up
    add_column :admin_stats, :ticketing_kits, :integer
    add_column :admin_stats, :donation_kits, :integer
    add_column :admin_stats, :tickets, :integer
    add_column :admin_stats, :tickets_sold, :integer
    add_column :admin_stats, :donations, :integer
    add_column :admin_stats, :fafs_donations, :integer
  end

  def self.down
    remove_column :admin_stats, :ticketing_kits
    remove_column :admin_stats, :donation_kits
    remove_column :admin_stats, :tickets
    remove_column :admin_stats, :tickets_sold
    remove_column :admin_stats, :donations
    remove_column :admin_stats, :fafs_donations
  end
end


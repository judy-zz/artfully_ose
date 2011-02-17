class DonationsBelongToOrganizations < ActiveRecord::Migration
  def self.up
    remove_column :donations, :producer_pid
    add_column :donations, :organization_id, :integer
  end

  def self.down
    remove_column :donations, :organization_id
    add_column :donations, :producer_pid
  end
end

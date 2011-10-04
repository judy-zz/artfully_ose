class CreateAdminStats < ActiveRecord::Migration
  def self.up
    create_table :admin_stats do |t|
      t.integer     :users
      t.integer     :logged_in_more_than_once
      t.integer     :organizations
      t.integer     :fa_connected_orgs
      t.integer     :active_fafs_projects
      t.timestamps
    end
  end

  def self.down
    drop_table :admin_stats
  end
end

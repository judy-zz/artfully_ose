class CleanupEvents < ActiveRecord::Migration
  def self.up
    remove_column :events, :state 
    remove_column :events, :city
    remove_column :events, :time_zone
    remove_column :events, :venue_name 
  end

  def self.down
  end
end

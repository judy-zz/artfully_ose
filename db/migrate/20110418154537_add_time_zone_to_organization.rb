class AddTimeZoneToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :time_zone, :string
  end

  def self.down
    remove_column :organizations, :time_zone
  end
end

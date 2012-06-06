class AddLifetimeValueToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :lifetime_value, :integer, :default => 0
  end

  def self.down
    remove_column :organizations, :lifetime_value
  end
end

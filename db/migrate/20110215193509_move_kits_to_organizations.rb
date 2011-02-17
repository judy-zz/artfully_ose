class MoveKitsToOrganizations < ActiveRecord::Migration
  def self.up
    remove_column :kits, :user_id
    add_column :kits, :organization_id, :integer
  end

  def self.down
    remove_column :kits, :organization
    add_column :kits, :user_id, :integer
  end
end

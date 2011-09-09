class RemoveRolesFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :roles_mask
  end

  def self.down
    add_column :users, :roles_mask, :integer
  end
end

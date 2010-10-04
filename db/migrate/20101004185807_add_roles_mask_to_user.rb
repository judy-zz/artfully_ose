class AddRolesMaskToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :roles_mask, :string
  end

  def self.down
    remove_column :users, :roles_mask
  end
end

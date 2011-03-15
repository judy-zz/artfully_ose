class RemoveRolesFromUser < ActiveRecord::Migration
  def self.up
    drop_table :user_roles
    drop_table :roles
    add_column :users, :roles_mask, :integer
  end

  def self.down
    remove_column :users, :roles_mask

    create_table :roles_users, :id => false do |t|
      t.references :role, :user
    end

    create_table :roles do |t|
      t.string :name
      t.timestamps
    end
  end
end

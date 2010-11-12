class UsersHaveManyRolesThroughUserRoles < ActiveRecord::Migration
  def self.up
    drop_table :roles_users
    create_table :user_roles do |t|
      t.references :role, :user
      t.timestamps
    end
  end

  def self.down
    drop_table :user_roles
    create_table :roles_users, :id => false do |t|
      t.references :role, :user
    end
  end
end

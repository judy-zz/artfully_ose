class AddPasswordResetToAdmins < ActiveRecord::Migration
  def self.up
    add_column :admins, :reset_password_token, :string
  end

  def self.down
    remove_column :admins, :reset_password_token
  end
end

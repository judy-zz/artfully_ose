class UpgradeDevise < ActiveRecord::Migration
  def up
    #Upgrading devise: https://github.com/plataformatec/devise/wiki/How-To:-Upgrade-to-Devise-2.0
    remove_column :users, :remember_token
    add_column    :users, :reset_password_sent_at, :datetime
    
    add_column    :admins, :reset_password_sent_at, :datetime
  end

  def down
    add_column    :users, :remember_token, :string
    remove_column :users, :reset_password_sent_at
    
    remove_column :admins, :reset_password_sent_at
  end
end

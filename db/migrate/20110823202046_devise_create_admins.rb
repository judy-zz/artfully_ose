#
# Modified per these instructions: https://github.com/plataformatec/devise/wiki/How-To:-Upgrade-to-Devise-2.0-migration-schema-style
#

class DeviseCreateAdmins < ActiveRecord::Migration
  def self.up
    create_table(:admins) do |t|
      
      ## Database authenticatable
      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""
      
      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      
      ## Lockable
      t.integer  :failed_attempts, :default => 0
      t.string   :unlock_token
      t.datetime :locked_at
      
      t.timestamps
    end

    add_index :admins, :email,                :unique => true
    add_index :admins, :unlock_token,         :unique => true
  end

  def self.down
    drop_table :admins
  end
end

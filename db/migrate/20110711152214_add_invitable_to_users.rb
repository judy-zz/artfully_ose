class AddInvitableToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string   :invitation_token, :limit => 60
      t.datetime :invitation_sent_at
      t.index    :invitation_token
    end

    change_column_null :users, :encrypted_password, true
  end

  def self.down
    change_table :users do |t|
      t.remove_index  :invitation_token
      t.remove        :invitation_token
      t.remove        :invitation_sent_at
    end

    change_column_null :users, :encrypted_password, false
  end
end

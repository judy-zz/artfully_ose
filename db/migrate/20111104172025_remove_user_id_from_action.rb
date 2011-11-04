class RemoveUserIdFromAction < ActiveRecord::Migration
  def self.up
    remove_column :actions, :user_id
  end

  def self.down
  end
end

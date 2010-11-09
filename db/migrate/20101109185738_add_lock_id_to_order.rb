class AddLockIdToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :lock_id, :string
  end

  def self.down
    remove_column :orders, :lock_id
  end
end

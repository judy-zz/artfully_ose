class RemoveLockFromOrders < ActiveRecord::Migration
  def self.up
    remove_column :orders, :lock_id
  end

  def self.down
    add_column :orders, :lock_id, :string
  end
end
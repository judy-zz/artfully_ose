class ChangeOrderIdToParentId < ActiveRecord::Migration
  def self.up
    rename_column :orders, :order_id, :parent_id
  end

  def self.down
    rename_column :orders, :parent_id, :order_id
  end
end

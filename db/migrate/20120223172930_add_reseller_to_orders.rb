class AddResellerToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :reseller_order_id, :integer
  end

  def self.down
    remove_column :orders, :reseller_order_id
  end
end

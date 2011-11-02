class RenameOrderToCart < ActiveRecord::Migration
  def self.up
    rename_table(:orders, :carts)
    rename_column(:donations, :order_id, :cart_id)
    rename_column(:purchasable_tickets, :order_id, :cart_id)
  end

  def self.down
    rename_table(:carts, :orders)
    rename_column(:donations, :cart_id, :order_id)
    rename_column(:purchasable_tickets, :cart_id, :order_id)
  end
end

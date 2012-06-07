class AddResellerToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :reseller_settled, :boolean
    add_column :items, :reseller_net, :integer
    add_column :items, :reseller_order_id, :integer
  end

  def self.down
    remove_column :items, :reseller_settled
    remove_column :items, :reseller_net
    remove_column :items, :reseller_order_id
  end
end

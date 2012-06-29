class AddOrderIndexToItems < ActiveRecord::Migration
  def self.up
    add_index :items, :order_id
    add_index :items, :show_id
    add_index :items, :created_at
  end

  def self.down
    remove_index :items, :order_id
    remove_index :items, :show_id
    remove_index :items, :created_at
  end
end

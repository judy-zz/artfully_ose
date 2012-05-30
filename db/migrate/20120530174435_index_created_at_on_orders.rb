class IndexCreatedAtOnOrders < ActiveRecord::Migration
  def self.up
    add_index :orders, :created_at
  end

  def self.down
    remove_index :orders, :created_at
  end
end

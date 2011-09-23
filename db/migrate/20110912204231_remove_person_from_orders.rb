class RemovePersonFromOrders < ActiveRecord::Migration
  def self.up
    remove_column :orders, :person_id
  end

  def self.down
    add_column :orders, :person_id, :integer
  end
end

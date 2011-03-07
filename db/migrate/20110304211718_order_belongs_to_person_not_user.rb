class OrderBelongsToPersonNotUser < ActiveRecord::Migration
  def self.up
    remove_column :orders, :user_id
    add_column :orders, :person_id, :integer
  end

  def self.down
    remove_column :orders, :person_id
    add_column :orders, :user_id, :integer
  end
end

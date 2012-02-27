class AddStiToCart < ActiveRecord::Migration
  def self.up
    add_column :carts, :type, :string
    add_column :carts, :reseller_id, :string
  end

  def self.down
    remove_column :carts, :type
    remove_column :carts, :reseller_id
  end
end

class CreateResellerItems < ActiveRecord::Migration
  def self.up
    create_table :reseller_items do |t|
      t.string  :state
      t.integer :product_id
      t.integer :price
      t.integer :realized_price
      t.integer :net
      t.string  :settlement_id
      t.integer :show_id 
      
      t.belongs_to :reseller_order
      t.timestamps
    end
  end

  def self.down
    drop_table :reseller_items
  end
end

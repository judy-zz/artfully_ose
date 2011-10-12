class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :state
      t.string :product_type
      t.integer :product_id
      t.integer :price
      t.integer :realized_price
      t.integer :net
      t.string :settlement_id

      t.string :fs_project_id
      t.string :nongift_amount
      t.boolean :is_noncash
      t.boolean :is_stock
      t.boolean :is_anonymous
      t.datetime :fs_available_on
      t.datetime :reversed_at
      t.string :reversed_note

      t.belongs_to :order
      t.belongs_to :performance
      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
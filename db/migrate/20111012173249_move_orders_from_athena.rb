class MoveOrdersFromAthena < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.string :transaction_id
      t.integer :price
      t.belongs_to :organization
      t.belongs_to :person
      t.belongs_to :order
      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
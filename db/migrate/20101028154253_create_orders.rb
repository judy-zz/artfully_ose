class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.string :state
      t.string :transaction_id
      t.belongs_to :person
      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end

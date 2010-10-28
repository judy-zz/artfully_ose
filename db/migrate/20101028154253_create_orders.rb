class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.string :state

      t.references :user
      t.string :transaction_id  # Transaction IDs are GUID

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end

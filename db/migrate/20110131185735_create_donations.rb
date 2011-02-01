class CreateDonations < ActiveRecord::Migration
  def self.up
    create_table :donations do |t|
      t.timestamps
      t.references :order
      t.integer :amount
      t.integer :producer_pid
    end
  end

  def self.down
    drop_table :donations
  end
end

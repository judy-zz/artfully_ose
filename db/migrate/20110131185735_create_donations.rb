class CreateDonations < ActiveRecord::Migration
  def self.up
    create_table :donations do |t|
      t.integer :amount
      t.belongs_to :order
      t.belongs_to :organization
      t.timestamps
    end
  end

  def self.down
    drop_table :donations
  end
end

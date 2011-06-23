class CreatePurchasableTicket < ActiveRecord::Migration
  def self.up
    create_table :purchasable_tickets do |t|
      t.references :order
      t.references :ticket
      t.string :lock_id
      t.timestamps
    end
  end

  def self.down
    drop_table :purchaseable_tickets
  end
end

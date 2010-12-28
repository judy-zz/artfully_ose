class CreatePurchasableTicket < ActiveRecord::Migration
  def self.up
    create_table :purchasable_tickets do |t|
      t.timestamps
      t.references :order
      t.references :ticket
    end
  end

  def self.down
    drop_table :purchaseable_tickets
  end
end

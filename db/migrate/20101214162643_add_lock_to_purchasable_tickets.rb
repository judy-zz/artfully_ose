class AddLockToPurchasableTickets < ActiveRecord::Migration
  def self.up
    add_column :purchasable_tickets, :lock_id, :string
  end

  def self.down
    remove_column :purchasable_tickets, :lock_id
  end
end
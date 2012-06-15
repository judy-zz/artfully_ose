class AddAvailableIndexToTickets < ActiveRecord::Migration
  def self.up
    add_index :tickets, [:section_id, :show_id, :state]
    add_index :tickets, :cart_id
  end

  def self.down
    remove_index :tickets, [:section_id, :show_id, :state]
    remove_index :tickets, :cart_id
  end
end

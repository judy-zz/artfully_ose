class AddAvailableIndexToTickets < ActiveRecord::Migration
  def self.up
    add_index :tickets, [:section_id, :show_id, :state]
  end

  def self.down
    remove_index :tickets, [:section_id, :show_id, :state]
  end
end

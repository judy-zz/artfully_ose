class AddIndexToTicketState < ActiveRecord::Migration
  def self.up
    add_index(:tickets, :state)
  end

  def self.down
    remove_index(:tickets, :state)
  end
end

class AddCartIdToTickets < ActiveRecord::Migration
  def self.up
    add_column :tickets, :cart_id, :integer
  end

  def self.down
    remove_column :tickets, :cart_id
  end
end

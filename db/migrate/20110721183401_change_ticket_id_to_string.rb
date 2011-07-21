class ChangeTicketIdToString < ActiveRecord::Migration
  def self.up
    change_table :purchasable_tickets do |t|
      t.change :ticket_id, :string
    end
  end

  def self.down
  end
end

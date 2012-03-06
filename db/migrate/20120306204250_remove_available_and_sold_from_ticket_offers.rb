class RemoveAvailableAndSoldFromTicketOffers < ActiveRecord::Migration

  def self.up
    remove_column :ticket_offers, :available
    remove_column :ticket_offers, :sold
  end

  def self.down
    add_column :ticket_offers, :available, :integer
    add_column :ticket_offers, :sold, :integer
  end

end

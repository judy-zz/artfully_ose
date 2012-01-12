class AddRejectionReasonToTicketOffers < ActiveRecord::Migration

  def self.up
    add_column :ticket_offers, :rejection_reason, :text
  end

  def self.down
    remove_column :ticket_offers, :rejection_reason
  end

end

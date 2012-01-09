class CreateTicketOffers < ActiveRecord::Migration

  def self.up
    create_table :ticket_offers do |t|
      t.references :organization
      t.references :show
      t.references :section
      t.references :reseller_profile
      t.string :status, :null => false, :default => "creating"
      t.integer :count, :null => false, :default => 0
      t.integer :available, :null => false, :default => 0
      t.integer :sold, :null => false, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :ticket_offers
  end

end

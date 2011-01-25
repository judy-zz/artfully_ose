class CreateTicketingKits < ActiveRecord::Migration
  def self.up
    create_table :ticketing_kits do |t|
      t.string :state
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :ticketing_kits
  end
end

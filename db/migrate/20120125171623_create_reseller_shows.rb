class CreateResellerShows < ActiveRecord::Migration

  def self.up
    create_table :reseller_shows do |t|
      t.string :state
      t.datetime :datetime
      t.references :reseller_event
      t.references :reseller_profile

      t.timestamps
    end

    remove_column :reseller_events, :datetime
    remove_column :reseller_events, :venue
    add_column :reseller_events, :venue_id, :integer
    add_column :reseller_events, :producer, :string
    add_column :reseller_events, :url, :string
  end

  def self.down
    drop_table :reseller_shows

    add_column :reseller_events, :datetime, :datetime
    add_column :reseller_events, :venue, :string
    remove_column :reseller_events, :venue_id
    remove_column :reseller_events, :producer
    remove_column :reseller_events, :url
  end

end

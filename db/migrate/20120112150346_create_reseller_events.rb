class CreateResellerEvents < ActiveRecord::Migration
  def self.up
    create_table :reseller_events do |t|
      t.references :reseller_profile
      t.datetime :datetime
      t.string :name
      t.string :venue
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :reseller_events
  end
end

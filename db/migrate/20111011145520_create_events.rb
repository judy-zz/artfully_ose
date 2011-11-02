class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name
      t.string :venue
      t.string :state
      t.string :city
      t.string :time_zone
      t.string :producer
      t.boolean :is_free
      t.belongs_to :organization
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
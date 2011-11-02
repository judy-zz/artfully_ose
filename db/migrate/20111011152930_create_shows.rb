class CreateShows < ActiveRecord::Migration
  def self.up
    create_table :shows do |t|
      t.string :state
      t.datetime :datetime
      t.belongs_to :event
      t.belongs_to :chart
      t.belongs_to :organization
    end
  end

  def self.down
    drop_table :shows
  end
end

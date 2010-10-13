class CreatePerformances < ActiveRecord::Migration
  def self.up
    create_table :performances do |t|
      t.string :title
      t.string :venue
      t.datetime :performed_on

      t.timestamps
    end
  end

  def self.down
    drop_table :performances
  end
end

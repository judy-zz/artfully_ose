class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string :name
      t.integer :capacity
      t.integer :price
      t.belongs_to :chart
    end
  end

  def self.down
    drop_table :sections
  end
end
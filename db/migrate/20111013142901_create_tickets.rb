class CreateTickets < ActiveRecord::Migration
  def self.up
    drop_table :tickets
    create_table :tickets do |t|
      t.string :venue
      t.string :section
      t.string :state
      t.integer :price
      t.integer :sold_price
      t.datetime :sold_at
      t.belongs_to :buyer
      t.belongs_to :show
      t.belongs_to :organization
      t.timestamps
    end
  end

  def self.down
    drop_table :tickets
  end
end
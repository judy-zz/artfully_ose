class CreateCharts < ActiveRecord::Migration
  def self.up
    create_table :charts do |t|
      t.string :name
      t.boolean :is_template
      t.belongs_to :event
      t.belongs_to :organization
    end
  end

  def self.down
    drop_table :charts
  end
end
class CreateSegments < ActiveRecord::Migration
  def self.up
    create_table :segments do |t|
      t.string :name
      t.string :terms
      t.belongs_to :organization
    end
  end

  def self.down
    drop_table :segments
  end
end

class AddSubtypeToActions < ActiveRecord::Migration
  def self.up
    add_column :actions, :subtype, :string
  end

  def self.down
    remove_column :actions, :subtype
  end
end

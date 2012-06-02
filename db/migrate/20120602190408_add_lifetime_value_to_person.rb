class AddLifetimeValueToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :lifetime_value, :integer, :default => 0
  end

  def self.down
    remove_column :people, :lifetime_value
  end
end

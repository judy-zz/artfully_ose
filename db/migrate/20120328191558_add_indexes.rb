class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :tickets, :show_id
    add_index :tickets, :organization_id
    
    add_index :shows, :organization_id
    add_index :shows, :event_id
  end

  def self.down
    remove_index :tickets, :show_id
    remove_index :tickets, :organization_id
    
    remove_index :shows, :organization_id
    remove_index :shows, :event_id
  end
end

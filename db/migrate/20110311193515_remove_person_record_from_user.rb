class RemovePersonRecordFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :person_id
  end

  def self.down
    add_column :users, :person_id, :integer
  end
end

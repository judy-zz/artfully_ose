class AddIndexToAddress < ActiveRecord::Migration
  def self.up
    add_index :addresses, :person_id
  end

  def self.down
    remove_index :addresses, :person_id
  end
end

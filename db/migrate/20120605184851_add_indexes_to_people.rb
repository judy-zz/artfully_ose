class AddIndexesToPeople < ActiveRecord::Migration
  def self.up
    add_index :people, [:organization_id, :email]
    add_index :people, :organization_id
  end

  def self.down
    remove_index :people, [:organization_id, :email]
    remove_index :people, :organization_id
  end
end

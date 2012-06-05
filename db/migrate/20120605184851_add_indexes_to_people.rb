class AddIndexesToPeople < ActiveRecord::Migration
  def self.up
    add_index :people, [:organization_id, :email]
    add_index :people, :organization_id
  end

  def self.down
  end
end

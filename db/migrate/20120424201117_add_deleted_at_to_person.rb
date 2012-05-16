class AddDeletedAtToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :deleted_at, :datetime
  end

  def self.down
    remove_column :people, :deleted_at
  end
end

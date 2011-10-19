class UpdateSettlementsAndItems < ActiveRecord::Migration
  def self.up
    rename_column :settlements, :performance_id, :show_id
    rename_column :items, :performance_id, :show_id
  end

  def self.down
    rename_column :settlements, :show_id, :performance_id
    rename_column :items, :show_id, :performance_id
  end
end

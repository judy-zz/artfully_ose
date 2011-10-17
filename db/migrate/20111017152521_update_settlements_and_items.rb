class UpdateSettlementsAndItems < ActiveRecord::Migration
  def self.up
    rename_column :settlements, :show_id, :show_id
    rename_column :items, :show_id, :show_id
  end

  def self.down
    rename_column :settlements, :show_id, :show_id
    rename_column :items, :show_id, :show_id
  end
end

class AddMongoIdToEverything < ActiveRecord::Migration
  def self.up
    add_column :tickets, :old_mongo_id, :string
    add_column :events, :old_mongo_id, :string
    add_column :charts, :old_mongo_id, :string
    add_column :sections, :old_mongo_id, :string
    add_column :people, :old_mongo_id, :string
    add_column :addresses, :old_mongo_id, :string
    add_column :orders, :old_mongo_id, :string
    add_column :actions, :old_mongo_id, :string
    add_column :shows, :old_mongo_id, :string
    add_column :settlements, :old_mongo_id, :string
  end

  def self.down
    remove_column :tickets, :old_mongo_id
    remove_column :events, :old_mongo_id
    remove_column :charts, :old_mongo_id
    remove_column :sections, :old_mongo_id
    remove_column :people, :old_mongo_id
    remove_column :addresses, :old_mongo_id
    remove_column :orders, :old_mongo_id
    remove_column :actions, :old_mongo_id
    remove_column :shows, :old_mongo_id
    remove_column :settlements, :old_mongo_id
  end
end

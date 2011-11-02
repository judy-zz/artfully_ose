class AddMongoIdToEverything < ActiveRecord::Migration
  def self.up
    add_column :tickets, :old_mongo_id, :string
    add_column :events, :old_mongo_id, :string
    add_column :charts, :old_mongo_id, :string
    add_column :sections, :old_mongo_id, :string
    add_column :people, :old_mongo_id, :string
  end

  def self.down
    remove_column :tickets, :old_mongo_id
    remove_column :events, :old_mongo_id
    remove_column :charts, :old_mongo_id
    remove_column :sections, :old_mongo_id
    remove_column :people, :old_mongo_id
  end
end

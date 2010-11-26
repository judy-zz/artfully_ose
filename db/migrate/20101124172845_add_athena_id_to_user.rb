class AddAthenaIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :athena_id, :string
  end

  def self.down
    remove_column :users, :athena_id
  end
end

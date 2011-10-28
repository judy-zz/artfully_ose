class AddCreatorIdToActions < ActiveRecord::Migration
  def self.up
    add_column :actions, :creator_id, :integer
  end

  def self.down
    remove_column :actions, :creator_id
  end
end

class AddTypeToSettlements < ActiveRecord::Migration

  def self.up
    add_column :settlements, :type, :string
  end

  def self.down
    remove_column :settlements, :type
  end

end

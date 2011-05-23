class AddFlagForAchInformationOnFile < ActiveRecord::Migration
  def self.up
    add_column :organizations, :ach_on_file, :boolean, :default => :false
  end

  def self.down
    remove_column :organizations, :ach_on_file
  end
end

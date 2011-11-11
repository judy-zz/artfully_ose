class ChangeSectionNameToText < ActiveRecord::Migration
  def self.up
    change_column :sections, :name, :text
  end

  def self.down
  end
end

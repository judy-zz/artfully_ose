class ChangeDetailsToText < ActiveRecord::Migration
  def self.up
    change_column :actions, :details, :text
  end

  def self.down
  end
end

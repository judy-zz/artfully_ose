class AddDetailsToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :details, :string
  end

  def self.down
    remove_column :orders, :details
  end
end

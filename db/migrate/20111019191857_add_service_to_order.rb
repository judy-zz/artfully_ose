class AddServiceToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :service_fee, :integer
  end

  def self.down
    remove_column :orders, :service_fee
  end
end

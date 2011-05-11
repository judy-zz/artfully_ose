class ChangeUserCustomerId < ActiveRecord::Migration
  def self.up
    change_column :users, :customer_id, :string
  end

  def self.down
  end
end

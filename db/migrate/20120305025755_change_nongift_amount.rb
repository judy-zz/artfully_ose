class ChangeNongiftAmount < ActiveRecord::Migration
  def self.up
    change_column :items, :nongift_amount, :integer
  end

  def self.down
    change_column :items, :nongift_amount, :string
  end
end

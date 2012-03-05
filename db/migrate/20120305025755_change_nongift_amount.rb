class ChangeNongiftAmount < ActiveRecord::Migration
  def self.up
    change_column :items, :nongift_amount, :integer
    execute "update items set nongift_amount = 0 where nongift_amount is NULL"
  end

  def self.down
    execute "update items set nongift_amount = NULL where nongift_amount = 0"
    change_column :items, :nongift_amount, :string
  end
end

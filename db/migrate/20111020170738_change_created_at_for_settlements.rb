class ChangeCreatedAtForSettlements < ActiveRecord::Migration
  def self.up
    change_column(:settlements, :created_at, :datetime)
  end

  def self.down
    change_column(:settlements, :created_at, :string)
  end
end

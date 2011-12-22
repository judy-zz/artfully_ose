class AddFeeToResellerProfiles < ActiveRecord::Migration

  def self.up
    add_column :reseller_profiles, :fee, :integer, :default => 100
  end

  def self.down
    remove_column :reseller_profiles, :fee
  end

end

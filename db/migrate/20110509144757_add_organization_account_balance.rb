class AddOrganizationAccountBalance < ActiveRecord::Migration
  def self.up
     add_column :organizations, :account_balance, :integer, :default => 0
  end

  def self.down
    remove_column :organizations, :account_balance
  end
end

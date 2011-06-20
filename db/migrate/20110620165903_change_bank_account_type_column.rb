class ChangeBankAccountTypeColumn < ActiveRecord::Migration
  def self.up
    rename_column(:bank_accounts, :type, :account_type)
  end

  def self.down
    rename_column(:bank_accounts, :type, :account_type)
  end
end

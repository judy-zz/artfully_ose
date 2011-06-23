class CreateBankAccounts < ActiveRecord::Migration
  def self.up
    create_table(:bank_accounts) do |t|
      # ACH Account
      t.string :routing_number
      t.string :number
      t.string :account_type

      # ACH Customer
      t.string :name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone

      t.belongs_to :organization
      t.timestamps
    end
  end

  def self.down
    drop_table(:bank_accounts)
  end
end

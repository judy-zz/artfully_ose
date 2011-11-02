class CreateSettlements < ActiveRecord::Migration
  def self.up
    create_table :settlements do |t|
      t.string :transaction_id
      t.string :ach_response_code
      t.string :fail_message
      t.string :created_at
      t.boolean :success
      t.integer :gross
      t.integer :realized_gross
      t.integer :net
      t.integer :items_count
      t.belongs_to :organization
      t.belongs_to :performance
      t.timestamps
    end
  end

  def self.down
    drop_table :settlements
  end
end

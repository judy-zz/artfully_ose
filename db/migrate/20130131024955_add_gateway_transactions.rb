class AddGatewayTransactions < ActiveRecord::Migration
  def change
    create_table :gateway_transactions do |t|
      t.string  :transaction_id
      t.boolean :success
      t.integer :service_fee
      t.integer :amount
      t.string  :message
      t.text  :response
      t.timestamps
    end
  end
end

class GatewayTransaction < ActiveRecord::Base
  has_many :orders, :primary_key => :transaction_id, :foreign_key => :transaction_id
  serialize :response
end
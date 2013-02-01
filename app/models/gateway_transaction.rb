class GatewayTransaction < ActiveRecord::Base
  include AdminTimeZone
  has_many :orders, :primary_key => :transaction_id, :foreign_key => :transaction_id
  serialize :response
  
  set_watch_for :created_at, :local_to => :self, :as => :admins
end
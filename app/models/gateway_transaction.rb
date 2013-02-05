class GatewayTransaction < ActiveRecord::Base
  include AdminTimeZone
  has_one :order, :primary_key => :transaction_id, :foreign_key => :transaction_id
  has_many :items, :through => :order
  serialize :response
  
  set_watch_for :created_at, :local_to => :self, :as => :admins

  #
  # For delayed_job
  #
  def perform
    self.save
  end
end
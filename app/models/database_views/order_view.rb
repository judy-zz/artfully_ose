class OrderView < ActiveRecord::Base
  set_table_name 'order_view'
  has_many :items, :foreign_key => 'order_id'
  
  default_scope :order => 'created_at DESC'
  scope :before, lambda { |time| where("created_at < ?", time) }
  scope :after,  lambda { |time| where("created_at > ?", time) }
  scope :imported, where("fa_id IS NOT NULL")
  scope :not_imported, where("fa_id IS NULL")
  scope :artfully, where("transaction_id IS NOT NULL")
  
  def total
    items.inject(0) {|sum, item| sum + item.price.to_i }
  end
end
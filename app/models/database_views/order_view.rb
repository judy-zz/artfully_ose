class OrderView < ActiveRecord::Base
  set_table_name 'order_view'
  has_many :items, :foreign_key => 'order_id'
  
  def total
    items.inject(0) {|sum, item| sum + item.price.to_i }
  end
end
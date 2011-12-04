class AddLocationAndPmToOrders < ActiveRecord::Migration
  def self.up
    add_column(:orders, :type, :string)
    add_column(:orders, :payment_method, :string)
    
    Order.all.each do |order|
      if !order.transaction_id.nil?
        order.type = 'WebOrder'
        order.payment_method = 'credit_card'
      elsif !order.fa_id.nil?
        order.type = 'FaOrder'
        order.payment_method = nil
      else
        order.type = 'ApplicationOrder'
        order.payment_method = nil
      end
      order.save
    end
  end

  def self.down
    remove_column(:orders, :type)
    remove_column(:orders, :payment_method)
  end
end

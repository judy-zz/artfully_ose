module Reseller
  class Cart < Cart
    belongs_to :reseller, :class_name => "Organization", :foreign_key => "reseller_id"
    
    def update_ticket_fee
      @fee_in_cents = (items_subject_to_fee.size * 100) + (items_subject_to_fee.size * reseller.reseller_profile.fee)
    end
    
    def checkout_class
      Reseller::Checkout
    end
  end
  
  class Checkout < Checkout 
    def order_class
      Reseller::Order
    end

    #
    # We can't take advantage of checkout.create_order because the reseller order and the sub-order need to point to the *same items*
    # checkout.create_order would create different items for each order
    #
    def create_order(order_timestamp)
      order = new_order(@cart.reseller, order_timestamp, @person)
      order << @cart.tickets
      order.save
    end
  end
  
  #
  # This is the order that resellers see.
  # Producers will receive and view ExternalOrders
  #
  class Order < Order  
    has_many :external_orders, :class_name => "ExternalOrder", :foreign_key => "reseller_order_id"
    has_many :items, :foreign_key => "reseller_order_id"
    
    #Rails wraps callbacks in the save transaction, so this is cool.
    before_save :set_items
    after_save :explode
    
    def set_items
      items.each do |item|
        item.reseller_order = self
      end
    end
    
    def reseller_fee
      items.inject(0) {|sum, item| sum + item.reseller_net.to_i }
    end
    
    def explode
      orders = {}
      
      items.each do |item|
        order = orders[item.product.organization.id] || ExternalOrder.new
        
        item.reseller_net        = @organization.reseller_profile.fee
        order.organization       = item.product.organization
        order.person             = @person
        order.transaction_id     = transaction_id
        order.service_fee        = service_fee
        order.payment_method     = payment_method
        order.reseller_order     = self
        order.items              << item
        
        orders[item.product.organization.id] = order
      end
      
      orders.each do |organization_id, order|
        order.save
      end
    end
    
    def location
      "Web"
    end
  end
end
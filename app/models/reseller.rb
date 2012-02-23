module Reseller
  class Cart < Cart
    attr_accessor :reseller
    
    def initialize(reseller)
      @reseller = Organization.find(reseller)
      super
    end
    
    def update_ticket_fee
      @fee_in_cents = (items_subject_to_fee.size * 100) + (items_subject_to_fee.size * reseller.reseller_profile.fee)
    end
  end
  
  class Checkout < Checkout 
    def order_class
      Reseller::Order
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
        order.organization       = @organization
        order.person             = @person
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
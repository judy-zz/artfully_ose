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
    
    #Rails wraps callbacks in the save transaction, so this is cool.
    after_save :explode
    
    def explode
      orders = {}
      
      items.each do |item|
        order = ExternalOrder.new
        order.organization       = @organization
        order.person             = @person
        order.reseller_order     = self
        orders[@organization.id] = order
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
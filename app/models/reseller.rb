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
  
  class Order < Order  
    def location
      "Reseller"
    end
  end
end
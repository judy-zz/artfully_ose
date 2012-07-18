module BoxOffice
  class Cart < Cart
    def fee_in_cents
      0
    end
    
    #
    # We don't lock tickets in the box office because the box office was poorly designed
    # and cannot add tickets to a cart later.  Thus, we had tickets being locked when selected, 
    # then new tickets being locked when they confirmed the sale.  This left many locked tickets
    # and box office personnel unable to sell out a show
    #
    def set_timeout(ticket)
    end
  end
  
  class Checkout < Checkout 
    def order_class
      BoxOffice::Order
    end
  end
  
  class Order < Order  
    def location
      "Box office"
    end
  end
end

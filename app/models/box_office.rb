module BoxOffice
  class Cart < Cart
    def fee_in_cents
      0
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

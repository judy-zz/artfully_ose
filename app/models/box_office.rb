module BoxOffice
  class Cart < Cart
    def update_ticket_fee
      @fee_in_cents = 0
    end
  end
  
  class Checkout < Checkout 
    def order_class
      BoxOffice::Order
    end
  end
  
  class Order < Order
  end
end
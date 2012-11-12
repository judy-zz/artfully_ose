class DollarsOffTicketsDiscountType < DiscountType
  def apply_discount_to_cart(cart)
    cart.tickets.each do |ticket|
      if ticket.price > 1000
        ticket.update_attributes(:cart_price => ticket.price - 1000)
      else
        ticket.update_attributes(:cart_price => 0)
      end
    end
    return cart
  end
end

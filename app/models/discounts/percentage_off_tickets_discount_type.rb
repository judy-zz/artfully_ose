class PercentageOffTicketsDiscountType < DiscountType
  def apply_discount_to_cart(cart)
    cart.tickets.each do |ticket|
      ticket.update_attributes(:cart_price => ticket.price - (ticket.price * 0.1))
    end
    return cart
  end
end

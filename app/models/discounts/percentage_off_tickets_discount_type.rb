class PercentageOffTicketsDiscountType < DiscountType
  discount_type :percentage_off_tickets

  def apply_discount_to_cart(cart)
    ensure_percentage_exists
    cart.tickets.each do |ticket|
      ticket.update_attributes(:cart_price => ticket.price - (ticket.price * @properties[:amount]))
    end
    return cart
  end

private

  def ensure_percentage_exists
    raise "Amount missing!" if @properties[:percentage].blank?
  end
end

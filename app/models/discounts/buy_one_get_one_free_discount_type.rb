class BuyOneGetOneFreeDiscountType < DiscountType
  discount_type :buy_one_get_one_free

  def apply_discount_to_cart(cart)
    if cart.tickets.count >= 2
      cart.tickets.first.update_attributes(:cart_price => 0)
    end
    return cart
  end

  def validate(discount)
    # Nothing to do here.
  end

  def to_s
    "Buy one, get one free"
  end
end

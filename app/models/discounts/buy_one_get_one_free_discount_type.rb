class BuyOneGetOneFreeDiscountType < DiscountType
  discount_type :buy_one_get_one_free

  def apply_discount_to_cart(cart)
    cart.tickets.each do |ticket|
      ticket.update_column(:discount_id, discount.id) unless ticket == tickets.last && tickets.count.odd?
    end
    cart.tickets.values_at(* cart.tickets.each_index.select {|i| i.odd?}).each do |ticket|
      ticket.update_column(:cart_price, 0)
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

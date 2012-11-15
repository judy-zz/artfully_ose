class DollarsOffTicketsDiscountType < DiscountType
  include ActionView::Helpers::NumberHelper
  discount_type :dollars_off_tickets

  def apply_discount_to_cart(cart)
    ensure_amount_exists
    cart.tickets.each do |ticket|
      if ticket.price > @properties[:amount]
        ticket.update_attributes(:cart_price => ticket.price - @properties[:amount])
      else
        ticket.update_attributes(:cart_price => 0)
      end
    end
    return cart
  end

  def validate(discount)
    discount.errors[:base] = "Amount must be filled in." unless @properties[:amount].present?
  end

  def to_s
    "#{number_to_currency(@properties[:amount].to_i / 100.00)} off each ticket"
  end

private

  def ensure_amount_exists
    raise "Amount missing!" if @properties[:amount].blank?
  end
end

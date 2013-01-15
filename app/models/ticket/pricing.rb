module Ticket::Pricing
  extend ActiveSupport::Concern

  def remove_from_cart
    self.update_column(:cart_id, nil)
  end

  def reset_price!
    update_column(:cart_price, self.price)
    update_column(:discount_id, nil)
  end 

  def set_cart_price
    self.cart_price ||= self.price
  end

  def cart_price
    self[:cart_price] || self.price
  end

  def change_price(new_price)
    unless self.committed? or new_price.to_i < 0
      self.price = new_price
      self.save!
    else
      return false
    end
  end
end
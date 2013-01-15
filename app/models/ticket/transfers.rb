module Ticket::Transfers
  extend ActiveSupport::Concern

  def sell_to(buyer, time=Time.now)
    begin
      self.buyer = buyer
      self.sold_price = self.price
      self.sold_at = time
      self.sell!
    rescue Transitions::InvalidTransition
      return false
    end
  end
  
  def exchange_to(buyer, time=Time.now)
    begin
      self.buyer = buyer
      self.sold_price = 0
      self.sold_at = time
      self.exchange!
    rescue Transitions::InvalidTransition => e
      puts e
      return false
    end
  end

  def comp_to(buyer, time=Time.now)
    begin
      self.buyer = buyer
      self.sold_price = 0
      self.sold_at = time
      self.comp!
    rescue Transitions::InvalidTransition => e
      puts e
      return false
    end
  end

  def return!(and_return_to_inventory = true)
    remove_from_cart
    self.buyer = nil
    self.sold_price = nil
    self.sold_at = nil
    self.buyer_id = nil
    save
    and_return_to_inventory ? return_to_inventory! : return_off_sale!
  end

end
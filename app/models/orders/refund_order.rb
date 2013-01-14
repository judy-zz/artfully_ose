class RefundOrder < Order
  include Unrefundable

  def self.location
    "Artful.ly"
  end
  
  def sell_tickets
  end
end
class CompOrder < Order  
  def location
    "Artful.ly"
  end
  
  def initialize
    super
    self.payment_method = ::CompPayment.payment_method
  end
  
  def sell_tickets
    all_tickets.each do |item|
      item.product.comp_to(self.person, self.created_at)
    end
  end
end
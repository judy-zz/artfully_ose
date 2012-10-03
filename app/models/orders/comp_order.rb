class CompOrder < Order  
  def location
    "Artful.ly"
  end
  
  def initialize
    super
    self.payment_method = ::CompPayment.payment_method
  end
end
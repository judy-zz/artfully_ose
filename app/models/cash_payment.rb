class CashPayment
  attr_accessor :amount

  def requires_authorization?
    false
  end
end
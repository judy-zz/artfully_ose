class CashPayment
  attr_accessor :amount, :customer

  def payment_method
    'cash'
  end

  def initialize(customer)
    @customer = customer
  end

  def requires_authorization?
    false
  end

  def requires_settlement?
    false
  end

  def amount=(amount)
    @amount = amount.to_i / 100.00
  end

  def reduce_amount_by(amount_in_cents)
    self.amount=((amount * 100) - amount_in_cents)
  end

  # DEBT: Because Orders are creating Orders for record keeping,
  # the transaction ID is stored.
  def transaction_id
    nil
  end
end
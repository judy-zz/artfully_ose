class CashPayment
  attr_accessor :amount, :customer

  def initialize(customer)
    @customer = customer
  end

  def requires_authorization?
    false
  end

  def requires_settlement?
    false
  end

  # DEBT: Because Orders are creating AthenaOrders for record keeping,
  # the transaction ID is stored.
  def transaction_id
    nil
  end
end
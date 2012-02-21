#This class is used to encapsulate a comp made through a payment interface (the box officem for example)  Comping from producer screens doesn't use this class
class CompPayment
  attr_accessor :person, :benefactor

  def payment_method
    'Comp'
  end

  #benefactor is the user that is doing the comping (current_user)
  #person is the person record receiving the comp.  It must have the id set
  def initialize(benefactor, person)
    @benefactor = benefactor
    @person = person
  end

  def requires_authorization?
    false
  end

  def requires_settlement?
    false
  end

  def amount=(amount)
    0
  end
  
  def amount
    0
  end

  def reduce_amount_by(amount_in_cents)
    0
  end
  
  def per_item_processing_charge
    lambda { |item| 0 }
  end

  # DEBT: Because Orders are creating Orders for record keeping,
  # the transaction ID is stored.
  def transaction_id
    nil
  end
end
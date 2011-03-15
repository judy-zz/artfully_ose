class Checkout
  attr_accessor :order, :payment

  def initialize(order, payment)
    self.order = order
    self.payment = payment
    self.payment.amount = self.order.total
  end

  def valid?
    !!order and !!payment and payment.valid?
  end

  def finish
    order.person = create_people_record
    order.pay_with(@payment)
    order.save
  end

  private
    def create_people_record
      AthenaPerson.create(:first_name => payment.customer.first_name, :last_name  => payment.customer.last_name,:email => payment.customer.email)
    end
end
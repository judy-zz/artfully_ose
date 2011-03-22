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
    order.person = find_or_create_people_record
    order.pay_with(@payment)
    order.save
  end

  private
    def find_or_create_people_record
      organization = order.organizations_from_tickets.first
      
      person = AthenaPerson.find_by_email_and_organization(payment.customer.email, organization)
      
      if person.nil?
        params = {
          :first_name      => payment.customer.first_name,
          :last_name       => payment.customer.last_name,
          :email           => payment.customer.email,
          # DEBT: This doesn't account for multiple organizations per order
          :organization_id => organization.id
        }
        person = AthenaPerson.create(params)
      end
      person
    end
end
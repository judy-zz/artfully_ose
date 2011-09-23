class OrderMailer < ActionMailer::Base
  default :from => "noreply@artful.ly"
  layout "mail"

  # TODO: Send using only information from AthenaOrder
  def confirmation_for(order)
    @order = order
    @person = order.person

    mail :to => @person.email, :subject => "Your Order"
  end
end

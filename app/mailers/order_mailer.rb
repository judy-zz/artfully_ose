class OrderMailer < ActionMailer::Base
  default :from => "support@artful.ly"
  layout "mail"

  def confirmation_for(order)
    @order = order
    @person = order.person

    mail :to => @person.email, :subject => "Your Order"
  end
end

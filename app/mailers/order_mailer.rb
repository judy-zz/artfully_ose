class OrderMailer < ActionMailer::Base
  default :from => "noreply@artful.ly"
  layout "mail"

  def confirmation_for(order)
    @order = order
    @user = order.user

    mail :to => @user.email, :subject => "Your Order"
  end
end

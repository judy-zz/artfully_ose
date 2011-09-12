class OrderMailer < ActionMailer::Base
  default :from => "noreply@artful.ly"
  layout "mail"

  # TODO: Send using only information from AthenaOrder
  def confirmation_for(order, athena_order, person)
    @order = order
    @person = person
    @athena_order = athena_order

    mail :to => @person.email, :subject => "Your Order"
  end
end

class BoxOffice::CheckoutsController < ApplicationController
  def new
    @cart = Order.find(params[:cart_id])
    @person = AthenaPerson.find(params[:person_id])
    @checkout = Checkout.new(@cart, CashPayment.new(@person.to_customer))
  end

  def create
    @cart = Order.find(params[:cart_id])
    @person = AthenaPerson.find(params[:person_id])
    @payment = CashPayment.new(@person.to_customer)
    @checkout = Checkout.new(@cart, @payment)

    if @checkout.finish
      redirect_to events_path, :notice => 'Items succesfully purchased.'
    else
      flash[:error] = "An error occured while trying to finish the order."
      render :new
    end

  end
end
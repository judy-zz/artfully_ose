class OrdersController < ApplicationController
  def create
    @order = Order.new
    @order.tickets = params[:tickets]
    if @order.save
      redirect_to edit_order_url(@order)
    else
      flash[:error] = @order.errors
      redirect_to :back
    end
  end

  def edit
    @order = Order.find(params[:id])
    @payment = Athena::Payment.new
  end

  def update
    @order = Order.find(params[:id])

    if @order.unfinished?
      @payment = Athena::Payment.new(params[:payment])
      @payment.amount = @order.total

      if @payment.valid?
        if payment_confirmed?
          submit_payment and return
        else
          request_confirmation and return
        end
      else
        render :edit and return
      end
    else
      redirect_to @order, :notice => "This order is already finished!"
    end
  end

  def destroy
    Order.find(params[:id]).destroy
    redirect_to root_url
  end

  def show
    @order = Order.find(params[:id])
  end

  private
    def payment_confirmed?
      not params[:confirmation].blank?
    end

    def submit_payment
      @order.pay_with(@payment)
      @order.save
      redirect_to @order, :notice => 'Thank you for your order!'
    end

    def request_confirmation
      @needs_confirmation = true
      flash[:notice] = 'Please confirm your payment details'
      render :edit
    end
end

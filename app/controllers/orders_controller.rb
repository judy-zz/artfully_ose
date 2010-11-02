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
    @payment = Payment.new
  end

  def update
    @order = Order.find(params[:id])

    if params[:payment] && @order.started?
      @payment = Payment.new(params[:payment])
      @payment.amount = 100 #TODO: Sum the order
      if @payment.valid?
        if payment_confirmed?
          @order.pay_with(@payment)
          @order.save
        else
          @needs_confirmation = true
        end
      end
    end
    render :edit
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
end

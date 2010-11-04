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

    if params[:payment] && @order.started? or @order.rejected?
      @payment = Payment.new(params[:payment])
      @payment.amount = @order.total
      if @payment.valid?
        if payment_confirmed?
          @order.pay_with(@payment)
          @order.save
          redirect_to @order and return
        else
          @needs_confirmation = true
          render :edit and return
        end
      else
        render :edit and return
      end
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
end

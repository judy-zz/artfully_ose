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
  end

  def update
    @order = Order.find(params[:id])

    case @order.state
      when "started"
        @payment = Payment.new(params[:payment])
        @order.add_payment(@payment)
        @order.save
      when "submitted"
        @payment = Payment.new(params[:payment])
        @order.confirm_payment(@payment)
        @order.save
    end
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to root_url
  end

  def show
    @order = Order.find(params[:id])
  end
end

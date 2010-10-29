class OrdersController < ApplicationController
  def create
    @order = Order.new
    @order.tickets = params[:tickets]
    if @order.valid?
      @order.save!
      redirect_to @order, :action => :edit
    else
      redirect_to :back
    end
  end

  def edit
    @order = Order.find(params[:id])
  end

  def update
  end

  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy
    redirect_to root_url
  end

  def show
    @payment = Payment.new
    @transaction = Transaction.find(params[:id])
  end

end

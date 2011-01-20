class OrdersController < ApplicationController
  def show
    respond_to do |format|
      format.widget
    end
  end

  def create
    tickets = params[:tickets].collect { |id| AthenaTicket.find(id) }
    current_order.add_items tickets

    unless current_order.save
      flash[:error] = current_order.errors
    end

    redirect_to order_url
  end

  def edit
  end

  def update
    tickets = params[:tickets].collect { |id| AthenaTicket.find(id) }
    current_order.add_items tickets

    unless current_order.save
      flash[:error] = current_order.errors
    end

    redirect_to order_url
  end

  def destroy
    current_order.destroy
    redirect_to order_url
  end
end

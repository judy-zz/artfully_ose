class OrdersController < ApplicationController
  def show
  end

  def create
    tickets = params[:tickets].collect { |id| AthenaTicket.find(id) }
    current_order.add_items tickets

    if current_order.save
      redirect_to current_order
    else
      flash[:error] = current_order.errors
      redirect_to :back
    end
  end

  def edit
  end

  def update
    tickets = params[:tickets].collect { |id| AthenaTicket.find(id) }
    current_order.add_items tickets

    if current_order.save
      redirect_to current_order
    else
      flash[:error] = current_order.errors
      redirect_to :back
    end
  end

  def destroy
    current_order.destroy
    redirect_to root_url
  end
end

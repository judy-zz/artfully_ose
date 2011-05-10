class RefundsController < ApplicationController
  def new
    @order = AthenaOrder.find(params[:order_id])
    @items = params[:items].collect { |item_id| AthenaItem.find(item_id) }
  end

  def create
    @order = AthenaOrder.find(params[:order_id])
    @items = params[:items].collect { |item_id| AthenaItem.find(item_id) }

    @refund = Refund.new(@order, @items)
    @refund.submit(:and_return => return_items?)

    if @refund.successful?
      if return_items?
        flash[:notice] = "Successfully refunded and returned #{@refund.items.size} tickets."
      else
        flash[:notice] = "Successfully refunded #{@refund.items.size} tickets."
      end
    else
      flash[:error] = "Unable to refund tickets."
    end

    redirect_to order_url(@order)
  end

  private

  def return_items?
    params[:commit] == "Refund and Return"
  end
end
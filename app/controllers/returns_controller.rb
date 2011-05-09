class ReturnsController < ApplicationController
  def create
    order = AthenaOrder.find(params[:order_id])
    items = params[:items].collect { |item_id| AthenaItem.find(item_id) }

    @return = Return.new(order, items)
    @return.submit

    if @return.successful?
      flash[:notice] = "Successfully returned #{@return.items.size} tickets."
    else
      flash[:error] = "Unable to return tickets."
    end

    redirect_to order_url(order)
  end

end
class RefundsController < ApplicationController
  def create
    order = AthenaOrder.find(params[:order_id])
    # Check for :all first?
    items = params[:items].collect { |item_id| AthenaItem.find(item_id) }
    Refund.new(order, items)

    refund.submit

    if refund.successful?
      flash[:notice] = "Successfully refunded #{refund.items_refunded} tickets."
    else
      flash[:error] = "Unable to refund tickets."
    end
  end
end
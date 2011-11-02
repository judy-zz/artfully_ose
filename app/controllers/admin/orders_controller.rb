class Admin::OrdersController < Admin::AdminController
  def index
    @orders = filtered_orders.paginate(:page => params[:page], :per_page => 50)
  end

  private

  def filtered_orders
    case params[:filter]
      when "processed" then Order.processed
      else Order.all
    end
  end
end
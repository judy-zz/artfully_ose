class Admin::OrdersController < Admin::AdminController
  def index
    @orders = filtered_orders.paginate(:page => params[:page], :per_page => 50)
  end

  private

  def filtered_orders
    case params[:filter]
      when "all" then Order.all
      else Order.processed
    end
  end
end
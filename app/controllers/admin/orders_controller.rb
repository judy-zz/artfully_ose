class Admin::OrdersController < Admin::AdminController
  def index
    @orders = filtered_orders
  end

  def artfully
    @orders = filtered_orders('artfully')
    render :index
  end
  
  def all
    @orders = filtered_orders('all')
    render :index
  end

  private
    def filtered_orders(filter = 'artfully')
      case filter
        when "all" then OrderView.all
        else OrderView.artfully
      end
    end
end
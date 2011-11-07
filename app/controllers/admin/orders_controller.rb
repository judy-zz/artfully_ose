class Admin::OrdersController < Admin::AdminController
  def index
    @orders = filtered_orders.paginate(:page => params[:page], :per_page => 50)
  end

  def artfully
    @orders = filtered_orders('artfully').paginate(:page => params[:page], :per_page => 50)
    render :index
  end
  
  def all
    @orders = filtered_orders('all').paginate(:page => params[:page], :per_page => 50)
    render :index
  end

  private
    def filtered_orders(filter = 'artfully')
      case filter
        when "all" then Order.all
        else Order.artfully
      end
    end
end
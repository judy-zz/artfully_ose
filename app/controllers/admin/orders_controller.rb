class Admin::OrdersController < Admin::AdminController
  def index
    if params[:search]
      @results = search(params[:search]).paginate(:page => params[:page], :per_page => 50)
      redirect_to order_path(@results.first.id) if @results.length == 1
    else
      @results = Order.all.sort{|a,b| b.timestamp <=> a.timestamp }.paginate(:page => params[:page], :per_page => 50)
    end
  end
end
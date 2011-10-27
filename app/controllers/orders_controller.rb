class OrdersController < ApplicationController
  def index
    authorize! :manage, Order
    if params[:search]
      @results = search(params[:search]).paginate(:page => params[:page], :per_page => 25)
      redirect_to order_path(@results.first.id) if @results.length == 1
    else
      @results = current_organization.orders.all.sort{|a,b| b.created_at <=> a.created_at }.paginate(:page => params[:page], :per_page => 25)
    end
  end

  def show
    @order = Order.find(params[:id])
    authorize! :view, @order
    @person = Person.find(@order.person_id)
    @total = @order.total
  end

  def sales
    authorize! :view, Order
    Time.zone = current_user.current_organization.time_zone

    @search = SaleSearch.new(params[:start], params[:stop], current_user.current_organization) do |results|
      results.paginate(:page => params[:page], :per_page => 25)
    end
  end

  private

  def search(query)
    begin
      orders = []
      orders << Order.find(query)
    rescue ActiveResource::ResourceNotFound
      ##TODO: Implement search by first name, last name, email, last four of CC number
      []
    rescue ActiveResource::ForbiddenAccess #occurs when search string == ""
      []
    end
  end

end
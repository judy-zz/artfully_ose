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

  def resend
    authorize! :view, Order
    @order = Order.find(params[:id])
    OrderMailer.delay.confirmation_for(@order)
    
    flash[:notice] = "A copy of the order receipt has been sent to #{@order.person.email}"
    redirect_to order_url(@order)
  end

  def sales
    authorize! :view, Order
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
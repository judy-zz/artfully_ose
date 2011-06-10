class OrdersController < ApplicationController
  def index
    authorize! :manage, AthenaOrder
    if params[:search]
      @results = search(params[:search]).paginate(:page => params[:page], :per_page => 25)
      redirect_to order_path(@results.first.id) if @results.length == 1
    else
      @results = AthenaOrder.find(:all, :params =>{ :organizationId => "eq#{current_user.current_organization.id}"}).paginate(:page => params[:page], :per_page => 10)
    end
  end

  def show
    @order = AthenaOrder.find(params[:id])
    authorize! :view, @order
    @person = AthenaPerson.find(@order.person_id)
    @total = 0
    @order.items.each{ |item| @total += item.price.to_i }
  end

  private

  def search(query)
    begin
      orders = []
      orders << AthenaOrder.find(query)
    rescue ActiveResource::ResourceNotFound
      ##TODO: Implement search by first name, last name, email, last four of CC number
      []
    rescue ActiveResource::ForbiddenAccess #occurs when search string == ""
      []
    end
  end

end
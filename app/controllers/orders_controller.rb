class OrdersController < ApplicationController
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

  def index
    if params[:search]
      @results = search(params[:search])
      redirect_to order_path(@results.id) if @results.is_a? AthenaOrder
    end
  end

  def show
    @order = AthenaOrder.find(params[:id])
    authorize! :view, @order

    @children = @order.children
    @person = AthenaPerson.find(@order.person_id)

    @total = 0
    @order.items.each{ |item| @total += item.price.to_i }
  end

  private

  def search(query)
    begin
      orders = AthenaOrder.find(query)
    rescue ActiveResource::ResourceNotFound
      ##TODO: Implement search by first name, last name, email, last four of CC number
      []
    rescue ActiveResource::ForbiddenAccess #occurs when search string == ""
      []
    end
  end

end
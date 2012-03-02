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

    @event = Event.find_by_id(params[:event_id]) if params[:event_id].present?
    @events = current_user.current_organization.events_with_sales
    @show = @event.shows.find_by_id(params[:show_id]) if @event && params[:show_id].present?
    @shows = current_user.current_organization.shows_with_sales

    search_terms = {
      :start        => params[:start],
      :stop         => params[:stop],
      :organization => current_user.current_organization,
      :event        => @event,
      :show         => @show
    }

    @search = SaleSearch.new(search_terms) do |results|
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

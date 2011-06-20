class OrdersController < ApplicationController
  def index
    authorize! :manage, AthenaOrder
    if params[:search]
      @results = search(params[:search]).paginate(:page => params[:page], :per_page => 25)
      redirect_to order_path(@results.first.id) if @results.length == 1
    else
      @results = AthenaOrder.find(:all, :params =>{ :organizationId => "eq#{current_user.current_organization.id}"}).sort{|a,b| b.timestamp <=> a.timestamp }.paginate(:page => params[:page], :per_page => 10)
    end
  end

  def show
    @order = AthenaOrder.find(params[:id])
    authorize! :view, @order
    @person = AthenaPerson.find(@order.person_id)
    @total = 0
    @order.items.each{ |item| @total += item.price.to_i }
  end

  def contributions
    authorize! :view, AthenaOrder
    begin
      Time.zone = current_user.current_organization.time_zone
      unless params[:commit].blank?
        @start = Time.zone.parse(Date.strptime(params[:start], "%m/%d/%Y").to_s)
        @stop  = Time.zone.parse(Date.strptime(params[:stop] , "%m/%d/%Y").to_s).end_of_day
      else
        @start = DateTime.now.in_time_zone(Time.zone).beginning_of_month
        @stop  = DateTime.now.in_time_zone(Time.zone).end_of_day
      end
      orders_in_range = AthenaOrder.in_range(@start, @stop, current_user.current_organization.id)
      @orders_with_donations = orders_in_range.select{|order| not order.items.select{|item| item.product_type == "Donation" }.empty?}
      @orders_with_donations = @orders_with_donations.sort{|a,b| b.timestamp <=> a.timestamp }.paginate(:page => params[:page], :per_page => 25)
    rescue ArgumentError
      flash[:alert] = "One or both of the dates entered are invalid."
      redirect_to :back
    end
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
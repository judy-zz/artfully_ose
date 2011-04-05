class OrdersController < ApplicationController

  def index
    if params[:search]
      results = search(params[:search])
      if results.class == AthenaOrder
        redirect_to order_path(results.id)
      end
      @results = results
    else
      @results = "No search performed"
    end
  end

  def show
    @order = AthenaOrder.find(params[:id])
    @person = AthenaPerson.find(@order.person_id)

    @total = 0
    @order.items.each{ |item| @total += item.price.to_i }
  end

  private

  def search(query)
    if ":ALL" == query
      orders = AthenaOrder.find(:all, :params =>{ :organizationId => "eq#{current_user.current_organization.id}"})
    else 
      begin
        orders = AthenaOrder.find(query)
      rescue ActiveResource::ResourceNotFound
        ##TODO: Implement search by first name, last name, email, last four of CC number
        orders = nil
      end     
    end

    orders
  end

end
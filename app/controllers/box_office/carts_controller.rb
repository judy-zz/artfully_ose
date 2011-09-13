class BoxOffice::CartsController < ApplicationController
  def show
    @cart = Order.find(params[:id])
    @buyers = find_buyers
  end

  def create
    @cart = Order.create
    @show = AthenaPerformance.find(params[:show_id])
    tickets = find_tickets(params[:quantity], @show)
    @cart.add_tickets(tickets)
    redirect_to box_office_cart_path(@cart)
  end

  def update
  end

  def destroy
  end

  private

  def find_buyers
    if params[:terms].present?
      people = AthenaPerson.search_index(params[:terms].dup, current_user.current_organization)
      flash[:error] = "No people matched your search terms." if people.empty?
    end
    people || []
  end

  def find_tickets(quantities, show)
    quantities.collect do |section_name, quantity|
      AthenaTicket.available({
        :performance_id => show.id,
        :section => section_name,
        :limit => quantity
      })
    end.flatten
  end

end
class ExchangesController < ApplicationController
  def new
    @events = AthenaEvent.find(:all, :params => { :organizationId => "eq#{current_user.current_organization.id}" })

    unless params[:event_id].blank?
      @event = AthenaEvent.find(params[:event_id])
      @performances = @event.upcoming_performances(:all)
      unless params[:performance_id].blank?
        @performance = AthenaPerformance.find(params[:performance_id])
        @tickets = @performance.tickets.select(&:on_sale?)
      end
    end
  end

  def create
    order = AthenaOrder.find(params[:order_id])
    items = params[:items].collect { |item_id| AthenaItem.find(item_id) }
    tickets = params[:tickets].collect { |ticket_id| AthenaTicket.find(ticket_id) }

    @exchange = Exchange.new(order, items, tickets)

    if @exchange.valid?
      @exchange.submit
      redirect_to order_url(order), :notice => "Successfully exchanged #{self.class.helpers.pluralize(items.length, 'item')}"
    else
      flash[:error] = "Unable to process exchange."
      redirect_to :back
    end
  end
end
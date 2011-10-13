class ExchangesController < ApplicationController
  def new
    order = Order.find(params[:order_id])
    items = params[:items].collect { |item_id| Item.find(item_id) }

    if items.all?(&:exchangeable?)
      @events = Event.find(:all, :params => { :organizationId => "eq#{current_user.current_organization.id}" })

      unless params[:event_id].blank?
        @event = Event.find(params[:event_id])
        @performances = @event.upcoming_performances(:all)
        unless params[:performance_id].blank?
          @performance = Show.find(params[:performance_id])
          @tickets = @performance.tickets.select(&:on_sale?)
        end
      end
    else
      flash[:error] = "Some of the selected items are not exchangable."
      redirect_to order_url(order)
    end
  end

  def create
    order = Order.find(params[:order_id])
    items = params[:items].collect { |item_id| Item.find(item_id) }
    tickets = params[:tickets].collect { |ticket_id| Ticket.find(ticket_id) } unless params[:tickets].nil?
    logger.debug("Beginning exchange")
    @exchange = Exchange.new(order, items, tickets)

    if tickets.nil?
      flash[:error] = "Please select tickets to exchange."
      redirect_to :back
    elsif @exchange.valid?
      logger.debug("Submitting exchange")
      @exchange.submit
      redirect_to order_url(order), :notice => "Successfully exchanged #{self.class.helpers.pluralize(items.length, 'item')}"
    else
      flash[:error] = "Unable to process exchange."
      redirect_to :back
    end
  end
end
class PerformancesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource(:class => "AthenaPerformance")

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to event_url(@performance.event)
  end

  def duplicate
    @performance = AthenaPerformance.find(params[:id])
    @new_performance = @performance.dup!
    @new_performance.save
    redirect_to event_url(@new_performance.event_id)
  end

  def new
    @performance = AthenaPerformance.new
    @event = AthenaEvent.find(params[:event_id])
    @charts = AthenaChart.find_by_event(@event)
    if @charts.empty?
       flash[:error] = "Please import a chart to this event before creating a new performance."
       redirect_to event_url(@event)
    end
    @performance.event_id=@event.id
    @performance.chart_id=nil
  end

  def create
    @performance = AthenaPerformance.new
    @event = AthenaEvent.find(params[:event_id])
    @performance.update_attributes(params[:athena_performance][:athena_performance])
    @performance.event_id=@event.id
    @performance.tickets_created = 'false'
    if @performance.save
      redirect_to event_url(@performance.event)
    else
      render :template => 'performances/new'
    end
  end

  def show
    @performance = AthenaPerformance.find(params[:id])
    @event = AthenaEvent.find(@performance.event_id)
    @performance.tickets = @performance.tickets.sort_by { |ticket| ticket.price }

    respond_to do |format|
      format.html
      format.widget
    end
  end

  def edit
    # Loaded and authorized by CanCan
  end

  def update
    @performance = AthenaPerformance.find(params[:id])
    @bulk_action = params[:bulk_action]

    if(!@bulk_action.nil?)
      bulk_edit_tickets params[:selected_tickets], @bulk_action
      redirect_to performance_url(@performance) and return
    else
      without_tickets do
        @performance.update_attributes(params[:athena_performance][:athena_performance])
        if @performance.save
          redirect_to event_url(@performance.event)
        else
          render :template => 'performances/new'
        end
      end
    end
  end

  def destroy
    @performance.destroy
    redirect_to event_url(@performance.event)
  end

  def createtickets
    @performance = AthenaPerformance.find(params[:id])
    AthenaTicketFactory.for_performance(@performance)
    @event = AthenaEvent.find(@performance.event_id)
    @charts = AthenaChart.find_by_event(@event)
    redirect_to performance_url(@performance)
  end

  private
    def without_tickets
      if @performance.tickets_created?
        flash[:alert] = 'Tickets have already been created.'
        redirect_to event_url(@performance.event) and return
      else
        yield
      end
    end

    def bulk_edit_tickets ticket_ids, action
      if ticket_ids.nil?
        flash[:error] = "You didn't select any tickets"
        return
      else
        ticket_ids.each do |ticket_id|
          @ticket = AthenaTicket.find(ticket_id)

          #TODO: Put this logic into @performance model?
          case action
            when "PUT_ON_SALE"
              @ticket.on_sale=true
              @ticket.save
            when 'TAKE_OFF_SALE'
              @ticket.on_sale=false
              @ticket.save
            when 'DELETE'
              @ticket.destroy
          end

          case action
            when "PUT_ON_SALE"
              @msg = "Put " + ticket_ids.size.to_s + " tickets on sale"
            when 'TAKE_OFF_SALE'
              @msg = "Took " + ticket_ids.size.to_s + " tickets off sale"
            when 'DELETE'
              @msg = "Deleted " + ticket_ids.size.to_s + " tickets "
            else
              @msg = "Please select some tickets"
          end
        end
      end
      flash[:notice] = @msg
    end
end
class PerformancesController < ApplicationController
  before_filter :authenticate_user!

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
    @performance = AthenaPerformance.find(params[:id])

    without_tickets do
      @event = AthenaEvent.find(params[:event_id])
      @charts = AthenaChart.find_by_event(@event)
    end
  end

  def update
    @performance = AthenaPerformance.find(params[:id])
    @bulk_action = params[:bulk_action]
    #if this is a bulk edit tickets action...
    if(!@bulk_action.nil?)
      @selected_tickets = params[:selected_tickets]
      
      if @selected_tickets.nil?
        flash[:error] = "You didn't select any tickets"
      else
      
        @msg = ''
        @selected_tickets.each do |ticket_id|
          @ticket = AthenaTicket.find(ticket_id)
          case @bulk_action
            when "PUT_ON_SALE"
              @ticket.on_sale=true
              @ticket.save
            when 'TAKE_OFF_SALE'
              @ticket.on_sale=false
              @ticket.save
            when 'DELETE'
              @ticket.destroy
            else
              @msg += ' bonk? '
          end
          @msg += ticket_id + ' '
        end
  
        flash[:notice] = "[" + params[:bulk_action] + "]"  + ' ' + @msg
      end
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
    @performance = AthenaPerformance.find(params[:id])

    without_tickets do
      @performance.destroy
      redirect_to event_url(@performance.event)
    end
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
end
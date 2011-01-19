class PerformancesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :class => "AthenaPerformance", :only => [ :edit, :destroy ]

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
    @performance.event = @event
    if @event.charts.empty?
       flash[:error] = "Please import a chart to this event before creating a new performance."
       redirect_to event_url(@event)
    end
  end

  def create
    @performance = AthenaPerformance.new
    @event = AthenaEvent.find(params[:event_id])
    @performance.update_attributes(params[:athena_performance][:athena_performance])
    @performance.event = @event
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
    @performance.tickets = @performance.tickets

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
    without_tickets do
      @performance.update_attributes(params[:athena_performance][:athena_performance])
      if @performance.save
        redirect_to event_url(@performance.event)
      else
        render :template => 'performances/new'
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
end
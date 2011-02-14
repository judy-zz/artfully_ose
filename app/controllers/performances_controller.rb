class PerformancesController < ApplicationController

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to event_url(@performance.event)
  end

  def duplicate
    @performance = AthenaPerformance.find(params[:id])
    authorize! :duplicate, @performance

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

    @performance.producer_pid = current_user.athena_id
    
    @performance.event = @event
    @performance.tickets_created = 'false'
    if @performance.valid? && @performance.save
      session[:performance] = nil
      flash[:notice] = 'Performance created on ' + @performance.formatted_performance_date + ' at ' + @performance.formatted_performance_time2(@event.time_zone)
      redirect_to event_url(@performance.event)
    else
      #render :action=>'new'
      session[:performance] = @performance
      redirect_to event_url(@performance.event)
    end
  end

  def show
    @performance = AthenaPerformance.find(params[:id])
    authorize! :view, @performance

    @event = AthenaEvent.find(@performance.event_id)
    @performance.tickets = @performance.tickets
    respond_to do |format|
      format.html
      format.widget
    end
  end

  def edit
    @performance = AthenaPerformance.find(params[:id])
    authorize! :edit, @performance
  end

  def update
    @performance = AthenaPerformance.find(params[:id])
    authorize! :edit, @performance

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
    @performance = AthenaPerformance.find(params[:id])
    authorize! :destroy, @performance
    
    @performance.destroy
    redirect_to event_url(@performance.event)
  end
  
  def put_on_sale
    @performance = AthenaPerformance.find(params[:id])
    authorize! :put_on_sale, @performance
    
    if @performance.tickets.empty?
      flash[:error] = 'Please create tickets for this performance before putting it on sale'
      redirect_to performance_url(@performance) and return
    end
    
    with_confirmation do
      @performance.put_on_sale
      flash[:notice] = 'Your performance is on sale!'
      redirect_to performance_url(@performance) and return
    end
  end
  
  def take_off_sale
    @performance = AthenaPerformance.find(params[:id])
    authorize! :take_off_sale, @performance
    with_confirmation do
      @performance.take_off_sale
      flash[:notice] = 'Your performance has been taken off sale!'
      redirect_to performance_url(@performance) and return
    end
  end

  def createtickets
    @performance = AthenaPerformance.find(params[:id])
    authorize! :edit, @performance

    AthenaTicketFactory.for_performance(@performance)
    @event = AthenaEvent.find(@performance.event_id)
    @charts = AthenaChart.find_by_event(@event)
    redirect_to performance_url(@performance)
  end

  private
    def with_confirmation
      if params[:confirm].nil?
        render params[:action] + '_confirm' and return
      else
        yield
      end
    end
    
    def without_tickets
      if @performance.tickets_created?
        flash[:alert] = 'Tickets have already been created for this performance'
        redirect_to event_url(@performance.event) and return
      else
        yield
      end
    end
end
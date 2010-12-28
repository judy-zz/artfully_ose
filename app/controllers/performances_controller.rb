class PerformancesController < ApplicationController
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
    @performance.event_id=@event.id
    @performance.chart_id=@event.chart_id
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
    @tickets = AthenaTicket.find(:all, :params => { :performanceId => "eq#{@performance.id}" })
    respond_to do |format|
      format.html
      format.widget
    end
  end
  
  def edit
    @performance = AthenaPerformance.find(params[:id])
    @event = AthenaEvent.find(params[:event_id])
    @charts = AthenaChart.find_by_event(@event)
  end
  
  def update
    @performance = AthenaPerformance.find(params[:id])
    @performance.update_attributes(params[:athena_performance][:athena_performance])
    if @performance.save
      redirect_to event_url(@performance.event)
    else
      render :template => 'performances/new'
    end
  end
  
  def destroy
    @performance = AthenaPerformance.find(params[:id])
    @event = AthenaEvent.find(params[:event_id])
    @performance.destroy
    redirect_to event_url(@event)
  end
  
  def createtickets
    @performance = AthenaPerformance.find(params[:id])
    AthenaTicketFactory.for_performance(@performance)
    @event = AthenaEvent.find(@performance.event_id)
    @charts = AthenaChart.find_by_event(@event)
    redirect_to performance_url(@performance)
  end
end
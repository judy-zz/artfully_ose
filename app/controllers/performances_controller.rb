class PerformancesController < ApplicationController
  def duplicate
    @performance = AthenaPerformance.find(params[:id])
    @new_performance = copy_performance @performance
    @new_performance.save
    redirect_to event_url(@performance.event_id)
  end
  
  def new
    @performance = AthenaPerformance.new
    @event = AthenaEvent.find(params[:event_id])
    @charts = AthenaChart.find_by_producer(current_user.athena_id)
  end
  
  def create
    @performance = AthenaPerformance.new
    @event = AthenaEvent.find(params[:event_id])
    @performance.update_attributes(params[:athena_performance][:athena_performance])
    @performance.event_id=@event.id
    @performance.chart_id=@event.chart_id
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

  private
    def copy_performance(source_performance)
      perf = AthenaPerformance.new
      perf.datetime = source_performance.datetime
      perf.event_id = source_performance.event_id
      perf
    end
end
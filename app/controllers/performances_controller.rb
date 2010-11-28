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
  end
  
  def create
    @performance = AthenaPerformance.new
    @event = AthenaEvent.find(params[:event_id])
    @performance.update_attributes(params[:athena_performance][:athena_performance])
    @performance.eventId=@event.id
    @performance.chartId=@event.chart.id
    if @performance.save
      redirect_to event_url(@performance.event)
    else
      render :template => 'performances/new'
    end
  end

  private
    def copy_performance(source_performance)
      perf = AthenaPerformance.new
      perf.datetime = source_performance.datetime
      perf.event_id = source_performance.event_id
      perf.chart_id = source_performance.chart_id
      perf
    end
end
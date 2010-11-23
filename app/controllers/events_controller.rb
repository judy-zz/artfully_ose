class EventsController < ApplicationController
  def create
    @event = AthenaEvent.new
    @chart = AthenaChart.new
    @chart.update_attributes(params[:athena_chart])
    
    if !@chart.save
      render :template => 'events/new'
    else    
      @event.update_attributes(params[:athena_event][:athena_event])
      @event.chart = @chart   
      if @event.save
        redirect_to event_url(@event)
      else
        render :template => 'events/new'
      end
    end
  end
  
  def show
    @event = AthenaEvent.find(params[:id])
  end
  
  def new
    @event = AthenaEvent.new
    @chart = AthenaChart.new
  end
end
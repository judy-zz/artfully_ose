class EventsController < ApplicationController
  def create
    @event = AthenaEvent.new
    @chart = AthenaChart.new
    @chart.update_attributes(params[:athena_chart])
    
    if !@chart.save
      render :template => 'events/new'
    else    
      @event.update_attributes(params[:athena_event][:athena_event])
      @event.producer_id = current_user.athena_id
      @event.chart = @chart   
      if @event.save
        redirect_to event_url(@event)
      else
        render :template => 'events/new'
      end
    end
  end
  
  def index
    @events = AthenaEvent.find(:all, :params => { :producerId => 'eq' + current_user.athena_id })
  end
  
  def show
    @event = AthenaEvent.find(params[:id])
    @performances = AthenaPerformance.find(:all, :params => { :eventId => 'eq' + @event.id })
  end
  
  def new
    @event = AthenaEvent.new
    @chart = AthenaChart.new
  end

  def edit
    @event = AthenaEvent.find(params[:id])
    @chart = AthenaChart.find(@event.chart_id)
  end

  def update
    @event = AthenaEvent.find(params[:id])
    @chart = AthenaChart.find(@event.chart_id)
    @chart.update_attributes(params[:athena_chart])
    
    if !@chart.save
      render :edit and return
    else    
      @event.update_attributes(params[:athena_event][:athena_event])
      if @event.save
        redirect_to event_url(@event)
      else
        render :edit and return
      end
    end
  end
end
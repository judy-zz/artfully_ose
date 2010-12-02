class EventsController < ApplicationController
  def create
    @event = AthenaEvent.new
    
    @event.update_attributes(params[:athena_event][:athena_event])
    @event.producer_pid = current_user.athena_id
    if @event.save
      redirect_to event_url(@event)
    else
      render :template => 'events/new'
    end
  end
  
  def index
    @events = AthenaEvent.find(:all, :params => { :producerPid => 'eq' + current_user.athena_id })
  end
  
  def show
    @event = AthenaEvent.find(params[:id])
    @event.performances= AthenaPerformance.find(:all, :params => { :eventId => 'eq' + @event.id })
  end
  
  def new
    @event = AthenaEvent.new
  end

  def edit
    @event = AthenaEvent.find(params[:id])
  end

  def update
    @event = AthenaEvent.find(params[:id])
        
    @event.update_attributes(params[:athena_event][:athena_event])
    if @event.save
      redirect_to event_url(@event)
    else
      render :edit and return
    end
  end
end
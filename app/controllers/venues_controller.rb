class VenuesController < ApplicationController
  def edit
    @event = Event.find(params[:event_id])
    authorize! :edit, @event
    @venue = @event.venue
  end
  
  def update
    @event = Event.find(params[:event_id])
    authorize! :edit, @event
    @venue = @event.venue
    @venue.update_attributes(params[:venue])
    redirect_to event_url(@event)
  end
end
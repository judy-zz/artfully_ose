class StatementsController < ApplicationController

  def index
    authorize! :view, Statement
    if params[:event_id].present?
      @event = Event.find(params[:event_id])
      authorize! :view, @event
      @played = @event.played_shows(:all)
      @statement = nil
      render :show and return
    else
      @events = current_organization.events
      @events.each {|event| authorize! :view, event}
    end
  end

  def show
    @show = Show.find(params[:id])
    authorize! :view, @show
    @event = @show.event
    @played = @event.played_shows(:all)
    @statement = Statement.for_show(@show, current_user.current_organization)
  end
end
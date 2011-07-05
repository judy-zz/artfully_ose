class StatementsController < ApplicationController
  before_filter :authenticate_user!
  
  def index    
    if(!params[:event_id].nil?)
      @event = AthenaEvent.find(params[:event_id])
      @played = @event.played_performances(:all)
      @statement = nil
      render :show and return
    else
      @events = AthenaEvent.find(:all, :params => { :organizationId => "eq#{current_user.current_organization.id}" })
    end
  end

  def show
    #TODO: cancan?
    @performance = AthenaPerformance.find(params[:performance_id])
    @event = @performance.event
    @played = @event.played_performances
    @statement = AthenaStatement.for_performance(params[:performance_id])
  end
end
class StatementsController < ApplicationController
  before_filter :authenticate_user!
  
  def index    
    if(!params[:event_id].nil?)
      @event = AthenaEvent.find(params[:event_id])
      authorize! :view, @event
      @played = @event.played_performances(:all)
      @statement = nil
      render :show and return
    else
      if current_user.current_organization.id.nil?
        authorize! :view, nil #throw CanCan::AccessDenied exception
      end
      @events = AthenaEvent.find(:all, :params => { :organizationId => "eq#{current_user.current_organization.id}" })
      @events.each{|event| authorize! :view, event}
    end

  end

  def show
    @performance = AthenaPerformance.find(params[:performance_id])
    authorize! :view, @performance
    @event = @performance.event
    @played = @event.played_performances
    @statement = AthenaStatement.for_performance(params[:performance_id], current_user.current_organization)
  end
end
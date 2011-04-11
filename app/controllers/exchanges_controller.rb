class ExchangesController < ApplicationController
  def new
    @events = AthenaEvent.find(:all, :params => { :organizationId => "eq#{current_user.current_organization.id}" })

    unless params[:event_id].blank?
      @event = AthenaEvent.find(params[:event_id])
      @performances = @event.performances
      unless params[:performance_id].blank?
        @performance = AthenaPerformance.find(params[:performance_id])
      end
    end
  end

  def create
  end
end
class StatementsController < ApplicationController

  def index
    authorize! :view, AthenaStatement.new
    if params[:event_id].present?
      @event = AthenaEvent.find(params[:event_id])
      authorize! :view, @event
      @played = @event.played_performances(:all)
      @statement = nil
      render :show and return
    else
      @events = AthenaEvent.find(:all, :params => { :organizationId => "eq#{current_user.current_organization.id}" })
      @events.each {|event| authorize! :view, event}
    end
  end

  def show
    @performance = AthenaPerformance.find(params[:id])
    authorize! :view, @performance
    @event = @performance.event
    @played = @event.played_performances
    @statement = AthenaStatement.for_performance(params[:id], current_user.current_organization)

    if @event.free?
      @statement.expenses.expenses.first.rate = "$0.00"
      @statement.expenses.expenses.first.expense = 0

      @statement.expenses.expenses.second.rate = "0"
      @statement.expenses.expenses.second.units = "0"
      @statement.expenses.expenses.second.expense = 0

      @statement.expenses.total.expense = 0

      @statement.sales.performances.each {|performance| performance.net_revenue = 0 }
    end

  end
end
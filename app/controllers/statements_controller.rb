class StatementsController < ApplicationController

  def index
    authorize! :view, AthenaStatement.new
    if params[:event_id].present?
      @event = Event.find(params[:event_id])
      authorize! :view, @event
      @played = @event.played_shows(:all)
      @statement = nil
      render :show and return
    else
      @events = Event.all
      @events.each {|event| authorize! :view, event}
    end
  end

  def show
    @show = Show.find(params[:id])
    authorize! :view, @show
    @event = @show.event
    @played = @event.played_shows
    @statement = AthenaStatement.for_show(params[:id], current_user.current_organization)
    @statement.sales.shows[0].datetime = @show.datetime
    if @event.free?
      @statement.expenses.expenses.first.rate = "$0.00"
      @statement.expenses.expenses.first.expense = 0

      @statement.expenses.expenses.second.rate = "0"
      @statement.expenses.expenses.second.units = "0"
      @statement.expenses.expenses.second.expense = 0

      @statement.expenses.total.expense = 0

      @statement.sales.shows.each {|show| show.net_revenue = 0 }
    end

  end
end
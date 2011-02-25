class EventsController < ApplicationController
  before_filter :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

  def create
    authorize! :create, AthenaEvent
    @event = AthenaEvent.new
    @event.update_attributes(params[:athena_event][:athena_event])
    @event.organization_id = current_user.current_organization.id

    if @event.save
      flash[:notice] = "Your event has been created."
      redirect_to event_url(@event)
    else
      flash[:error] = "Your event has not been created."
      render :new
    end
  end

  def index
    authorize! :view, AthenaEvent
    user = params[:user_id].blank?? current_user : User.find(params[:user_id])
    @events = AthenaEvent.find(:all, :params => { :organizationId => "eq#{user.current_organization.id}" })
  end

  def show
    @event = AthenaEvent.find(params[:id])
    authorize! :view, @event
    @performance = session[:performance].nil? ? AthenaPerformance.new : session[:performance]
    @charts = AthenaChart.find_templates_by_organization(current_user.current_organization).sort_by { |chart| chart.name }
    @chart = AthenaChart.new
    #Incrementing DateTime.now by one day and @event.performances.last.datetime.in_time_zone(@event.time_zone) by 86,400 seconds (one day)
    @next_performance_datetime = @event.performances.empty? ? (DateTime.now + 1) : (@event.performances.last.datetime.in_time_zone(@event.time_zone) + 86400)
  end

  def new
    authorize! :create, AthenaEvent
    @event = AthenaEvent.new
  end

  def edit
    @event = AthenaEvent.find(params[:id])
    authorize! :edit, @event
  end

  def update
    @event = AthenaEvent.find(params[:id])
    authorize! :edit, @event

    @event.update_attributes(params[:athena_event][:athena_event])
    if @event.save
      flash[:notice] = "Your event has been updated."
      redirect_to event_url(@event)
    else
      flash[:error] = "Your event has not been updated."
      render :edit
    end
  end

  def destroy
    @event = AthenaEvent.find(params[:id])
    authorize! :destroy, @event
    @event.destroy
    redirect_to events_url
  end

end

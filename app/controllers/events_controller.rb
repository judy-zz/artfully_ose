class EventsController < ApplicationController
  before_filter :authenticate_user!, :except => [ :show ]

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

  def create
    authorize! :create, AthenaEvent
    @event = AthenaEvent.new
    @event.update_attributes(params[:athena_event][:athena_event])
    @event.producer_pid = current_user.person.id
    if @event.save
      flash[:notice] = "Your event has been created."
      redirect_to event_url(@event)
    else
      flash[:error] = "Your event has not been created."
      render :new
    end
  end

  def index
    user = params[:user_id].blank?? current_user : User.find(params[:user_id])
    @events = AthenaEvent.find(:all, :params => { :producerPid => "eq#{user.person.id}" })
    authorize! :view, AthenaEvent

    respond_to do |format|
      format.html
      format.jsonp  { render_jsonp @events.to_json }
    end
  end

  def show
    @event = AthenaEvent.find(params[:id])
    authorize! :view, @event unless request.format == "jsonp"
    @performance = session[:performance].nil? ? AthenaPerformance.new : session[:performance]

    if user_signed_in?
      @charts = AthenaChart.find_templates_by_producer(current_user.person.id).sort_by { |chart| chart.name }
      @chart = AthenaChart.new
    end

    respond_to do |format|
      format.html
      format.jsonp  { render_jsonp @event.to_widget_json }
    end
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

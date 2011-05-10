class EventsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :find_event, :only => [ :show, :edit, :update, :destroy ]
  before_filter :upcoming_performances, :only => :show

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
    @events = AthenaEvent.find(:all, :params => { :organizationId => "eq#{user.current_organization.id}" }).paginate(:page => params[:page], :per_page => 10)
  end

  def show
    authorize! :view, @event
    @performance = session[:performance].nil? ? @event.next_perf : session[:performance]
    @charts = AthenaChart.find_templates_by_organization(current_user.current_organization).sort_by { |chart| chart.name }
    @chart = AthenaChart.new
  end

  def new
    authorize! :create, AthenaEvent
    @event = AthenaEvent.new
  end

  def edit
    authorize! :edit, @event
  end

  def update
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
    authorize! :destroy, @event
    @event.destroy
    redirect_to events_url
  end

  private

  def find_event
    @event = AthenaEvent.find(params[:id])
  end

  def upcoming_performances
    @upcoming = @event.upcoming_performances
  end

end

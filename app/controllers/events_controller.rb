class EventsController < ApplicationController
  respond_to :html, :json
  before_filter :authenticate_user!

  before_filter :find_event, :only => [ :show, :edit, :update, :destroy, :widget ]
  before_filter :upcoming_performances, :only => :show

  def create
    @event = AthenaEvent.new(params[:athena_event][:athena_event])
    @event.organization_id = current_user.current_organization.id
    begin
      authorize! :create, @event
    rescue CanCan::AccessDenied
      flash[:error] = "Please upgrade your account to create paid events."
      render :new and return
    end

    if @event.save
      @charts = find_charts.each do |chart|
        @event.assign_chart(chart)
      end
      redirect_to event_url(@event)
    else
      render :new
    end
  end

  def index
    authorize! :view, AthenaEvent
    @events = AthenaEvent.find(:all, :params => { :organizationId => "eq#{current_user.current_organization.id}" }).paginate(:page => params[:page], :per_page => 10)
  end

  def show
    authorize! :view, @event
    @performance = session[:performance].nil? ? @event.next_perf : session[:performance]
    @charts = AthenaChart.find_templates_by_organization(current_user.current_organization).sort_by { |chart| chart.name }
    @chart = AthenaChart.new

    respond_to do |format|
      format.json do
        render :json => @event.as_full_calendar_json.to_json
      end
      format.html
    end

  end

  def new
    @event = AthenaEvent.new
    authorize! :new, @event
    @event.producer = current_user.current_organization.name
    @templates = AthenaChart.find_templates_by_organization(current_user.current_organization).sort_by { |chart| chart.name }
  end

  def edit
    authorize! :edit, @event
  end

  def assign
    @event = AthenaEvent.find(params[:event_id])
    @chart = AthenaChart.find(params[:athena_chart][:id])
    @event.assign_chart(@chart)

    flash[:error] = @event.errors.full_messages.to_sentence unless @event.errors.empty?

    redirect_to event_url(@event)
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

  def widget
  end

  private

  def find_event
    @event = AthenaEvent.find(params[:id])
  end

  def find_charts
    ids = params[:charts] || []
    ids.collect { |id| AthenaChart.find(id) }
  end

  def upcoming_performances
    @upcoming = @event.upcoming_performances
  end
end

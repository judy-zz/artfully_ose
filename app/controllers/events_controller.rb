class EventsController < ApplicationController
  respond_to :html, :json

  before_filter :find_event, :only => [ :show, :edit, :update, :destroy, :widget, :image, :storefront_link ]
  before_filter :upcoming_shows, :only => :show
  after_filter :save_event_to_session, :except => [:destroy, :index]
  after_filter :clear_event_from_session, :only => :destroy

  def create
    @event = Event.new(params[:event])
    @templates = current_organization.charts.template
    @event.organization_id = current_user.current_organization.id
    @event.is_free = !(current_user.current_organization.can? :access, :paid_ticketing)
    @event.venue.organization_id = current_user.current_organization.id
    @event.venue.time_zone = current_user.current_organization.time_zone

    if @event.save
      redirect_to edit_event_url(@event)
    else
      render :new
    end
  end

  def index
    authorize! :view, Event
    @events = current_organization.events.paginate(:page => params[:page], :per_page => 25)
  end

  def show
    authorize! :view, @event
    @shows = @event.shows.paginate(:page => params[:page], :per_page => 25)
    @next_show = @event.next_show

    @charts = current_organization.charts.template
    @chart = Chart.new

    respond_to do |format|
      format.json do
        render :json => @event.as_full_calendar_json
      end

      format.html do
        render :show
      end
    end

  end

  def new
    @event = current_organization.events.build(:producer => current_organization.name)
    @event.venue = Venue.new
    authorize! :new, @event
    @templates = current_organization.charts.template
  end

  def edit
    authorize! :edit, @event
  end
  
  def image
    authorize! :edit, @event
  end

  def assign
    @event = Event.find(params[:event_id])
    @chart = Chart.find(params[:chart][:id])
    @event.assign_chart(@chart)

    flash[:error] = @event.errors.full_messages.to_sentence unless @event.errors.empty?

    redirect_to event_url(@event)
  end

  def update    
    authorize! :edit, @event

    @event.update_attributes(params[:event])
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

  def storefront_link
  end

  private
    def save_event_to_session
      session[:event_id] = @event.id
    end

    def clear_event_from_session
      session[:event_id] = nil
    end

    def find_event
      @event = Event.find(params[:id])
    end

    def find_charts
      ids = params[:charts] || []
      ids.collect { |id| Chart.find(id) }
    end

    def upcoming_shows
      @upcoming = @event.upcoming_shows
    end
end

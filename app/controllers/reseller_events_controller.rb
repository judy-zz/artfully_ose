class ResellerEventsController < ApplicationController

  before_filter :find_reseller_profile, :except => [ :stream ]
  before_filter :adjust_datetime_to_organization_time_zone, :except => [ :stream ]
  before_filter :authorize_reseller_profile, :except => [ :index, :stream ]
  before_filter :find_reseller_event, :only => [ :show, :edit, :update, :destroy ]

  def index
    @reseller_events = current_user.current_organization.reseller_events.alphabetical.all
    @reselling_offers = @reseller_profile.ticket_offers.includes(:show => { :event => :reseller_attachments }).accepted.all
  end

  def show
    @next_reseller_show = @reseller_event.next_show
  end

  def new
    @reseller_event = ResellerEvent.new
    @reseller_event.venue = Venue.new
  end

  def create
    @reseller_event = ResellerEvent.new(params[:reseller_event])
    @reseller_event.reseller_profile = @reseller_profile

    if @reseller_event.save
      flash[:notice] = "Your event has been created."
      redirect_to organization_reseller_events_path(@organization)
    else
      flash.now[:error] = "There was an error while creating your new reseller event."
      render :new
    end
  end

  def edit
  end

  def update
    if @reseller_event.update_attributes(params[:reseller_event])
      flash[:notice] = "Your event has been updated."
      redirect_to organization_reseller_events_path(@organization)
    else
      flash.now[:error] = "There was an error in updating your reseller event."
      render :edit
    end
  end

  def destroy
    @reseller_event.destroy

    redirect_to organization_reseller_events_path(@organization)
  end

  def stream
    @organization = Organization.find(params[:organization_id])
    @reseller_profile = @organization.reseller_profile
    @reseller_events = @organization.reseller_events.includes(:reseller_profile).all
    @ticket_offers = @reseller_profile.ticket_offers.includes(:show => :event).on_calendar.all

    @reseller_events.map! do |event|
      {
        :title => event.name,
        :start => event.datetime_local_to_organization.to_s(:fullcalendar),
        :allDay => false
      }
    end

    @ticket_offers.map! do |ticket_offer|
      {
        :title => ticket_offer.show.event.name,
        :start => ticket_offer.show.datetime_local_to_event.to_s(:fullcalendar),
        :allDay => false
      }
    end

    render :json => [ @reseller_events, @ticket_offers ].flatten.to_json
  end

  protected

  def find_reseller_profile
    @organization = Organization.find(params[:organization_id])
    @reseller_profile = @organization.reseller_profile

    if @reseller_profile.nil?
      flash[:error] = "You do not have a reseller profile."
      redirect_to root_path
    end
  end

  def adjust_datetime_to_organization_time_zone
    if params[:reseller_event] && params[:reseller_event][:datetime].present?
      datetime = params[:reseller_event][:datetime]
      time_zone = @organization.time_zone
      datetime = ActiveSupport::TimeZone.create(time_zone).parse(datetime)
      params[:reseller_event][:datetime] = datetime
    end
  end

  def authorize_reseller_profile
    authorize! :manage, @reseller_profile
  end

  def find_reseller_event
    @reseller_event = @reseller_profile.reseller_events.find(params[:id])
    @venue = @reseller_event.venue
    @shows = @reseller_event.reseller_shows.paginate(:page => params[:page], :per_page => 25)
  end

end

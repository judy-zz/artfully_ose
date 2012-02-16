class ResellerEventsController < ApplicationController

  before_filter :find_reseller_profile, :except => [ :stream ]
  before_filter :adjust_datetime_to_organization_time_zone, :except => [ :stream ]
  before_filter :authorize_reseller_profile, :except => [ :index, :stream ]
  before_filter :find_reseller_event, :only => [ :show, :edit, :update, :destroy ]

  def index
    @reseller_events = current_user.current_organization.reseller_events.alphabetical.all
    @reselling_offers = @reseller_profile.ticket_offers.includes(:show => { :event => :reseller_attachments }).accepted.all

    if @reseller_events.blank? && @reselling_offers.blank?
      redirect_to new_organization_reseller_event_path(@organization)
    end
  end

  def show
    @next_reseller_show = @reseller_event.next_show
    @reseller_attachment = @reseller_event.attachment_by(@reseller_profile)

    respond_to do |format|
      format.html
      format.json do
        render :json => @reseller_event.as_full_calendar_json(:published_only => false)
      end
    end
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
      render :edit
    end
  end

  def destroy
    @reseller_event.destroy

    redirect_to organization_reseller_events_path(@organization)
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

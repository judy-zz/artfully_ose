class ResellerShowsController < ApplicationController

  before_filter :find_reseller_profile
  before_filter :authorize_reseller_profile
  before_filter :find_reseller_event
  before_filter :find_reseller_show, :except => [ :index, :new, :create ]

  def new
    @reseller_show = @reseller_event.next_show
  end

  def create
    @reseller_show = ResellerShow.new(params[:reseller_show])
    @reseller_show.reseller_profile = @reseller_profile
    @reseller_show.reseller_event = @reseller_event

    if @reseller_show.save
      flash[:notice] = "Show created on #{l @reseller_show.datetime_local_to_reseller_event, :format => :date_at_time}"
      redirect_to organization_reseller_event_path(@organization, @reseller_event)
    else
      flash[:error] = "There was a problem creating your show."
      render :new
    end
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

  def authorize_reseller_profile
    authorize! :manage, @reseller_profile
  end

  def find_reseller_event
    @reseller_event = @reseller_profile.reseller_events.find(params[:reseller_event_id])
    @venue = @reseller_event.venue
  end

  def find_reseller_show
    @reseller_event.reseller_shows.find(params[:id])
  end

end

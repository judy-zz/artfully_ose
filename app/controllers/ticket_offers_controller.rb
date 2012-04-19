class TicketOffersController < ApplicationController

  before_filter :find_organization, :only => [ :index, :new, :create ]
  before_filter :find_ticket_offer, :except => [ :index, :new, :create ]
  before_filter :load_available_offer_options, :only => [ :new, :create ]

  def index
    if @reseller_profile
      @offers_to_me = @reseller_profile.ticket_offers.includes(:show => :event).visible_to_reseller.to_a
      @offers_to_me.sort!
    end

    @my_offers = @organization.ticket_offers.includes(:show => :event).to_a
    @my_offers.sort!
  end

  def show
    @ticket_offer = TicketOffer.find(params[:id])
  end

  def new
    @ticket_offer = TicketOffer.new(params[:ticket_offer])
    @ticket_offer.reseller_profile = ResellerProfile.find_by_id(params[:reseller_profile_id])
    @event = Event.find(params[:event_id]) if params[:event_id].present?
    @event_id = if @event then @event.id else @ticket_offer.event_id end
  end

  def create
    @ticket_offer = TicketOffer.new(params[:ticket_offer])
    @ticket_offer.organization = @organization
    @ticket_offer.status = "offered"

    if @ticket_offer.save
      redirect_to ticket_offers_path
    else
      render :action => "new"
    end
  end

  def update
    if @ticket_offer.update_attributes!(params[:ticket_offer])
      flash[:notice] = "Ticket offer rejected."
    else
      flash[:error] = "There was a problem in rejecting that offer."
    end

    redirect_to ticket_offers_path
  end

  def destroy
    @ticket_offer.destroy

    redirect_to ticket_offers_url
  end

  def accept
    @ticket_offer.accept!

    redirect_to ticket_offers_url, :notice => "You have accepted this ticket offer."
  end

  def decline
  end

  protected

  def find_organization
    @organization = current_user.current_organization
    @reseller_profile = @organization.reseller_profile
    authorize! :edit, @organization
  end

  def find_ticket_offer
    @ticket_offer = TicketOffer.find(params[:id])
    @organization = @ticket_offer.organization
    authorize! :edit, @ticket_offer
  end

  def load_available_offer_options
    # Get the master list of resellers.
    @reseller_profiles = ResellerProfile.joins(:organization).order("organizations.name").all

    # Grab the list of Events.
    @events = @organization.events.includes(:shows)

    # Build an EventID -> Shows hash.
    @shows = @events.to_h { |event| [ event.id, event.shows.unplayed.all ] }

    # Build a ShowID -> Sections hash.
    @sections = @shows.values.flatten.to_h { |show| [ show.id, show.tickets.includes(:section).map(&:section).uniq ] }

    # Build a list of ticket counts per section.
    @counts = {}
    @shows.map do |event_id, shows|
      shows.each do |show|
        show.
          tickets.
          resellable.
          select("section_id, COUNT(*) AS count").
          group("section_id").
          each do |t|
            @counts[show.id] ||= {}
            @counts[show.id][t.section_id] = t.count
          end
      end
    end
  end

end

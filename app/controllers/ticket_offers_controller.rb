class TicketOffersController < ApplicationController

  before_filter :find_organization, :only => [ :index, :new, :create ]
  before_filter :find_ticket_offer, :except => [ :index, :new, :create ]

  def index
    @ticket_offers = TicketOffer.all
  end

  def show
    @ticket_offer = TicketOffer.find(params[:id])
  end

  def new
    @ticket_offer = TicketOffer.new(params[:ticket_offer])
    @reseller_profiles = ResellerProfile.joins(:organization).order("organizations.name").all
  end

  def create
    @ticket_offer = TicketOffer.new(params[:ticket_offer])
    @ticket_offer.organization = @organization

    if @ticket_offer.save
      edit_path = edit_organization_ticket_offer_path(@organization, @ticket_offer)
      redirect_to edit_path
    else
      render :action => "new"
    end
  end

  def edit
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

  def update
    if params[:ticket_offer][:status] == "rejected"
      @ticket_offer.decline! params[:ticket_offer][:rejection_reason]
      redirect_to root_path, :notice => "You have rejected this ticket offer."
      return
    end

    if @ticket_offer.update_attributes(params[:ticket_offer])
      @ticket_offer.offer!
      path = event_show_path(@ticket_offer.show.event, @ticket_offer.show)

      redirect_to path, :notice => 'Your ticket offer has been sent to the reseller.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @ticket_offer.destroy

    redirect_to ticket_offers_url
  end

  def accept
    @ticket_offer.accept!

    redirect_to root_path, :notice => "You have accepted this ticket offer."
  end

  def decline
  end

  protected

  def find_organization
    @organization ||= Organization.find(params[:organization_id])
    authorize! :edit, @organization
  end

  def find_ticket_offer
    @organization ||= Organization.find(params[:organization_id])
    @ticket_offer = @organization.ticket_offers.find(params[:id])
    authorize! :edit, @ticket_offer
  end

end

class TicketOffersController < ApplicationController

  before_filter :find_organization
  before_filter :find_ticket_offer, :only => [ :show, :edit, :update, :destroy, :accept, :decline, :confirm_decline ]

  def index
    @ticket_offers = TicketOffer.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ticket_offers }
    end
  end

  def show
    @ticket_offer = TicketOffer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ticket_offer }
    end
  end

  def new
    @ticket_offer = TicketOffer.new(params[:ticket_offer])
    @reseller_profiles = ResellerProfile.joins(:organization).order("organizations.name").all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ticket_offer }
    end
  end

  def create
    @ticket_offer = TicketOffer.new(params[:ticket_offer])
    @ticket_offer.organization = @organization

    respond_to do |format|
      if @ticket_offer.save
        edit_path = edit_organization_ticket_offer_path(@organization, @ticket_offer)
        format.html { redirect_to(edit_path, :notice => 'Ticket offer was successfully created.') }
        format.xml  { render :xml => @ticket_offer, :status => :created, :location => @ticket_offer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ticket_offer.errors, :status => :unprocessable_entity }
      end
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
    respond_to do |format|
      if @ticket_offer.update_attributes(params[:ticket_offer])
        @ticket_offer.offer!
        path = event_show_path(@ticket_offer.show.event, @ticket_offer.show)

        format.html { redirect_to(path, :notice => 'Your ticket offer has been sent to the reseller.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ticket_offer.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @ticket_offer.destroy

    respond_to do |format|
      format.html { redirect_to(ticket_offers_url) }
      format.xml  { head :ok }
    end
  end

  def accept
    @ticket_offer.accept!

    redirect_to root_path, :notice => "You have accepted this ticket offer."
  end

  def decline
    @ticket_offer.decline!

    redirect_to root_path, :notice => "You have rejected this ticket offer."
  end

  def confirm_decline
  end

  protected

  def find_organization
    @organization = Organization.find(params[:organization_id])
    authorize! :edit, @organization
  end

  def find_ticket_offer
    @ticket_offer = @organization.ticket_offers.find(params[:id])
  end

end

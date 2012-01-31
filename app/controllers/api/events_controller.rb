class Api::EventsController < ApiController

  def index
    # Load info about the requested organization.
    @organization = Organization.find(params[:organization_id])
    @reseller_profile = @organization.reseller_profile

    # Standard Events
    @events = @organization.events.published.includes(:reseller_attachments).to_a

    if @reseller_profile
      # Reselling Events
      @ticket_offers = @reseller_profile.ticket_offers.on_calendar.includes(:show => :event)
      @events += @ticket_offers.map(&:show).map(&:event)

      # Reseller Events
      @events += @reseller_profile.reseller_events.published.includes(:reseller_attachments).to_a
    end

    # Remove any duplicated events.
    @events.uniq!

    # Build the array we'll send to the user.
    @events.map! do |e|
      e.as_json(:methods => ["venue"]).tap do |json|
        json.merge! "shows" => e.shows.published.as_json

        if @reseller_profile
          attachments = e.reseller_attachments.where(:reseller_profile_id => @reseller_profile.id)
          json.merge! "attachments" => attachments
        end
      end
    end

    respond_to do |format|
      format.json { render :json => @events }
    end
  end

  def show
    #This is a migration hack so that installed widgets don't need to update their code
    #if no event was found by old_mongo_id, try to find by id
    #We have to try old_mongo_id first b/c Rails will mung 4fhoewhf83083 into 4
    #and it'll pick up the wrong id
    @event = Event.find_by_old_mongo_id(params[:id])

    if @event.nil?
      @event = Event.find(params[:id])
    end

    respond_to do |format|
      format.json  { render :json => @event.as_widget_json }
    end
  end

end

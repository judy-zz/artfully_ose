class Api::ShowsController < ApiController

  def index
    # Load info about the requested organization.
    @organization = Organization.find(params[:organization_id])
    @reseller_profile = @organization.reseller_profile

    # Standard Shows
    @shows = @organization.shows.published.includes(:event => :reseller_attachments).to_a

    if @reseller_profile
      # Reselling Shows
      @ticket_offers = @reseller_profile.ticket_offers.on_calendar.includes(:show => :event)
      @shows += @ticket_offers.map(&:show)
      
      # Reseller Shows
      @shows += @reseller_profile.reseller_shows.published.includes(:event => :reseller_attachments).to_a
    end

    # Remove any duplicated events.
    @shows.uniq!

    # Build the array we'll send to the user.
    @shows.map! do |s|
      s.as_json.tap do |json|
        json.merge! "event" => s.event.as_json(:methods => ["venue"])

        if @reseller_profile
          attachments = s.event.reseller_attachments.where(:reseller_profile_id => @reseller_profile.id)
          json.merge! "attachments" => attachments
        end
      end
    end

    respond_to do |format|
      format.json { render :json => @shows }
    end
  end

end

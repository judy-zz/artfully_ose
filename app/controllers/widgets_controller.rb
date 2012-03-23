#
# This is the widget builder that orgs use to build widget code to deploy on their website.  Used from within the app
#
class WidgetsController < ApplicationController
  def new
    @events = current_organization.events
    @widget_options = [["Sell tickets to an event", "Event"], ["Receive donations", "Donations"], ["Sell tickets and receive donations", "Both"]]
    @events_array = @events.map { |event| [event.name, event.id] }
    @events_array.insert(0, ["", ""])
  end
  
  def create
    if wants_donation?      
      @event = nil
      @organization = current_user.current_organization
      @donation_extras = true
      @wants_donation = true
    end
    
    if wants_event?
      @event = Event.find(params[:event_id]) unless params[:event_id].blank?
      @donation_extras = false
      @wants_event = true
    end   
    
    @jquery = (params[:jquery] == 'yes') ? false : true
    
    render :layout => false
  end
  
  def wants_event?
    params[:widget_type] == 'event' || params[:widget_type] == 'both'
  end
  
  def wants_donation?
    params[:widget_type] == 'donations' || params[:widget_type] == 'both'
  end
end
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
  
  end
end
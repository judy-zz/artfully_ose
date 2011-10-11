class Admin::EventsController < Admin::AdminController
  def show
    @event = Event.find(params[:id])
  end
end
class Admin::EventsController < Admin::AdminController
  def show
    @event = AthenaEvent.find(params[:id])
  end
end
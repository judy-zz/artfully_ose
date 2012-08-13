class Store::EventsController < Store::StoreController
  def show
    @event = Event.find(params[:id])
  end
end
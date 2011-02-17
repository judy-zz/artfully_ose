class Store::EventsController < Store::StoreController
  def show
    @event = AthenaEvent.find(params[:id])
  end
end
class Store::EventsController < Store::StoreController
  def show
    @event = Event.find(params[:id])
    
    #This is a migration hack so that installed widgets don't need to update their code
    #if no event was found by id, try to find by old_mongo_id
    if @event.nil?
      @event = Event.find_by_old_mongo_id(params[:id])
    end
  end
end
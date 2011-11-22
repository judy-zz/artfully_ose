class Api::EventsController < ApiController

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

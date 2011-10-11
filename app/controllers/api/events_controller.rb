class Api::EventsController < ApiController

  def show
    @event = Event.find(params[:id])
    respond_to do |format|
      format.json  { render :json => @event.as_widget_json }
    end
  end

end

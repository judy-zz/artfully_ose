class Api::EventsController < ApiController

  def show
    @event = AthenaEvent.find(params[:id])
    respond_to do |format|
      format.json  { render :json => @event.to_widget_json }
    end
  end

end

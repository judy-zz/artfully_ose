class Api::EventsController < ApiController

  def show
    @event = AthenaEvent.find(params[:id])
    respond_to do |format|
      format.html
      format.jsonp  { render_jsonp @event.to_widget_json }
    end
  end
end

class Api::TicketsController < ApiController

  def index
    @tickets = AthenaTicket.search(params)
    respond_to do |format|
      format.jsonp { render :json => @tickets.to_json }
    end
  end

end
class Api::TicketsController < ApiController
  def index
    @tickets = AthenaTicket.available(params.reject { |k,v| %w( action controller format callback _ ).include? k })
    respond_to do |format|
      format.json { render :json => @tickets.to_json }
    end
  end
end
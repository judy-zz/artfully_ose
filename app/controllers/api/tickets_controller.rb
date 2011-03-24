class Api::TicketsController < ApiController

  def index
    @tickets = AthenaTicket.search(params.reject { |k,v| %w( action controller format callback _ ).include? k })
    ap @tickets
#    respond_to do |format|
#      format.json { render :json => @tickets.to_json }
#    end
  end

end
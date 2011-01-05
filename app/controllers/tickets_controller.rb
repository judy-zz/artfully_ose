class TicketsController < ApplicationController
  def index
    @tickets = AthenaTicket.search(params)
    respond_to do |format|
      format.jsonp  { render_jsonp (@tickets.to_json) }
    end
  end
end

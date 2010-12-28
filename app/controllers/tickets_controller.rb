class TicketsController < ApplicationController
  def index
    @tickets = AthenaTicket.search(params)
    respond_to do |format|
      format.html
      format.widget
    end
  end

  def show
    @ticket = AthenaTicket.find(params[:id])
  end
end

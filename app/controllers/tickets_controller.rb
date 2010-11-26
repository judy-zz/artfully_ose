class TicketsController < ApplicationController
  def index
    @tickets = AthenaTicket.search(params)
  end

  def show
    @ticket = AthenaTicket.find(params[:id])
  end
end

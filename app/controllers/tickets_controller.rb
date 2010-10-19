class TicketsController < ApplicationController
  def index
    @tickets = Ticket.search(params)
  end

  def show
    @ticket = Ticket.find(params[:id])
  end
end

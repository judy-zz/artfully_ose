class Athena::TicketsController < ApplicationController
  def index
    @tickets = Athena::Ticket.search(params)
  end

  def show
    @ticket = Athena::Ticket.find(params[:id])
  end
end

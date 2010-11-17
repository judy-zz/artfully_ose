class TicketsController < ApplicationController
  def index
    @tickets = AthenaTicket.search(params)
    render :template => 'athena_tickets/index'
  end

  def show
    @ticket = AthenaTicket.find(params[:id])
    render :template => 'athena_tickets/show'
  end
end

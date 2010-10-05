class TicketsController < ApplicationController
  def index
    #TODO: Move this into the model and perform intersection on known fields.
    search_for = {}
    search_for[:PRICE] = params[:PRICE] unless params[:PRICE].blank?
    search_for[:PERFORMANCE] = params[:PERFORMANCE] unless params[:PERFORMANCE].blank?
    @tickets = Ticket.find(:all, :params => search_for) unless search_for.empty? 
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def show
    @ticket = Ticket.find(params[:id])
  end
end

class TicketsController < ApplicationController
  def index
    @tickets = Ticket.find(:all, :params => { :q => params[:q] })
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

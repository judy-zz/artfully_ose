class TicketsController < ApplicationController

  before_filter :clean_params

  def index
    @tickets = Ticket.find(:all, :params => params) 
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

  private
    def clean_params
      params.delete_if { |key, value| value.blank? }
    end
end

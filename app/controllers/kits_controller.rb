class KitsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @kits = current_user.kits
  end

  def new
    @kit = TicketingKit.new
  end

  def create
    kit = TicketingKit.new(params[:kit])
    current_user.kits << kit
    flash[:notice] = "Congratulations, you've activated the ticketing kit" if kit.activated?
    redirect_to kits_url
  end
end
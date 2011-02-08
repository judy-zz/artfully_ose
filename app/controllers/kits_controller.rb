class KitsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @kits = []
    @kits << TicketingKit.new unless current_user.kits.any? { |kit| kit.is_a? TicketingKit }
  end

  def create
    @kit = Kit.new.becomes(Kernel.const_get(params[:type]))
    @kit.type = params[:type]
    current_user.kits << @kit
    if @kit.activated?
      flash[:notice] = "Congratulations, you've activated the ticketing kit"
    else
      flash[:error] = @kit.errors[:requirements].join(", ")
    end
    redirect_to kits_url
  end

  def update
    @kit = Kit.find(params[:id])
    @kit.activate!
    check_activation
    redirect_to kits_url
  end

  private
    def check_activation
      if @kit.activated?
        flash[:notice] = "Congratulations, you've activated the ticketing kit"
      else
        flash[:error] = @kit.errors[:requirements].join(", ")
      end
    end
end
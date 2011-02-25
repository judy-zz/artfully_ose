class KitsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @kits = current_user.current_organization.kits
  end

  def create
    @kit = Kernel.const_get(params[:type]).new
    @kit.type = params[:type]
    current_user.current_organization.kits << @kit
    if @kit.activated?
      flash[:notice] = "Congratulations, you've activated the #{params[:type]}"
    elsif @kit.pending?
      flash[:notice] = "Your request has been sent in for approval."
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
class KitsController < ApplicationController
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

  def new_donation_kit
    with_donation_kit_details do 
      
    @kit = DonationKit.new
    @kit.type = "DonationKit"

    with_donation_kit_details do
      current_user.current_organization.kits << @kit
      if @kit.activated?
        flash[:notice] = "Congratulations, you've activated the #{params[:type]}"
      elsif @kit.pending?
        flash[:notice] = "Your request has been sent in for approval."
      else
        flash[:error] = @kit.errors[:requirements].join(", ")
      end
    end
      redirect_to kits_url
    end
  end

  private
    def check_activation
      if @kit.activated?
        flash[:notice] = "Congratulations, you've activated the ticketing kit"
      else
        flash[:error] = @kit.errors[:requirements].join(", ")
      end
    end

    def with_donation_kit_details
      if params[:donation_type].blank?
        flash[:info] = "Please select what kind of donations you would be accepting."
      else
        yield
      end
    end

end
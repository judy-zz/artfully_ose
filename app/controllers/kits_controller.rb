class KitsController < ApplicationController
  def index
    @kits_hash = kits_to_hash(current_user.current_organization.kits)
  end

  def create
    @kit = Kernel.const_get(params[:type]).new
    @kit.type = params[:type]

    add_kit(params[:type])

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
#      with_donation_kit_details do
#        #add_kit("DonationKit")
#      end
#      redirect_to kits_url
    end
  end

  def new_501c3_kit
    @kit = DonationKit.new
    @organization = Organization.find(current_user.current_organization.id)

    unless params[:donation_kit].nil?
      @organization.taxable_organization_name = params[:donation_kit][:organization][:taxable_organization_name]
      @organization.ein = params[:donation_kit][:organization][:ein]
      @organization.save

      @kit.type = "DonationKit"
      @organization.kits << @kit

      redirect_to kits_url
    end

  end

  def new_fafs_kit  
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
      else
        yield
      end
    end

    def add_kit(type)
      @kit = Kernel.const_get(type).new
      @kit.type = type

      can_add_kit = true
      current_user.current_organization.kits.each{ |kit|
        if kit.type == @kit.type
          can_add_kit = false
          break
        end
      }

      if can_add_kit
        current_user.current_organization.kits << @kit

        if @kit.activated?
          flash[:notice] = "Congratulations, you've activated the #{@kit.type}"
        elsif @kit.pending?
          flash[:notice] = "Your request has been sent in for approval."
        else
          flash[:error] = @kit.errors[:requirements].join(", ")
        end

      else
        flash[:error] = "You already have a #{@kit.type}"
      end
    end

    def kits_to_hash(kits)
      donation_kit = nil
      ticketing_kit = nil
      kits.each{|kit| if kit.type == "DonationKit"; donation_kit = kit end; if kit.type == "TicketingKit"; ticketing_kit = kit end}
      kits_hash = {"DonationKit"=> donation_kit, "TicketingKit"=>ticketing_kit}
    end

end
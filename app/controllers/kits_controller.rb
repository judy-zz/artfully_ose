class KitsController < ApplicationController
  def index
    @kits = current_user.current_organization.available_kits
  end

  def new
    @kit = Kernel.const_get(params[:type].camelize).new
    @kit.organization_id = current_user.current_organization
  end

  def alternatives
    @kit = Kernel.const_get(params[:type].camelize).new
    @kits = @kit.alternatives.collect(&:new)
    @kits << @kit
  end

  def create
    @kit = Kernel.const_get(params[:type].camelize).new
    add_kit(params[:type].camelize)
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
    @kit = RegularDonationKit.new
    @organization = Organization.find(current_user.current_organization.id)

    unless params[:donation_kit].nil?
      @organization.legal_organization_name = params[:donation_kit][:organization][:legal_organization_name]
      @organization.ein = params[:donation_kit][:organization][:ein]
      @organization.save

      @kit.type = "DonationKit"
      @organization.kits << @kit

      AdminMailer.donation_kit_notification(@kit).deliver
      ProducerMailer.donation_kit_notification(@kit, current_user).deliver
      redirect_to new_501c3_kit_confirmation_path
    end
  end

  def new_501c3_kit_confirmation
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

      begin
        current_user.current_organization.kits << @kit
        if @kit.activated?
          flash[:notice] = "Congratulations, you've activated the #{@kit.type}"
        elsif @kit.pending?
          flash[:notice] = "Your request has been sent in for approval."
        else
          flash[:error] = @kit.errors[:requirements].join(", ")
        end
      rescue Kit::DuplicateError
        flash[:error] = "You already have a #{@kit.type}"
      end
    end
end
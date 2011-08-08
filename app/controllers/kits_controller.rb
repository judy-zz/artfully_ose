class KitsController < ApplicationController
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to dashboard_path, :alert => exception.message
  end

  def new
    authorize! :edit, current_user.current_organization
    @kit = Kernel.const_get(params[:type].camelize).new
    @kit.organization = current_user.current_organization
    if @kit.requirements_met?
      render "#{@kit.type.underscore.pluralize}/activate"
    else
      #Display friendly explanatory message if the donation kit has no tax information, display the error message if partial or incorrect information was given
      if @kit.type == "RegularDonationKit"
        if (@kit.organization.ein.blank? and @kit.organization.legal_organization_name.blank?)
          flash[:notice] = "Please enter your organization's tax information so that this kit may be activated."
        else
          errs = @kit.errors[:requirements].to_sentence     
          flash[:error] = errs
        end
      end

      render "#{@kit.type.underscore.pluralize}/requirements"
    end
  end

  def alternatives
    authorize! :view, current_user.current_organization
    @kit = Kernel.const_get(params[:type].camelize).new
    @kits = @kit.alternatives.collect(&:new)
    @kits << @kit
    render "#{@kit.type.underscore.pluralize}/alternatives"
  end

  def create
    authorize! :edit, current_user.current_organization
    @kit = Kernel.const_get(params[:type].camelize).new
    add_kit(params[:type].camelize)
    redirect_to @kit.organization
  end

  def update
    authorize! :edit, current_user.current_organization
    @kit = Kit.find(params[:id])
    @kit.activate!
    check_activation
    redirect_to @kit.organization
  end

  private
    def check_activation
      if @kit.activated?
        flash[:notice] = "Congratulations, you've activated the ticketing kit"
      else
        flash[:error] = @kit.errors[:requirements].join(", ")
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
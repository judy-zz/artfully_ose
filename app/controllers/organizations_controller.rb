class OrganizationsController < ApplicationController
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

  def index
    if current_user.is_in_organization?
      redirect_to organization_url(current_user.current_organization)
    else
      redirect_to new_organization_url
    end
  end

  def show
    @organization = Organization.find(params[:id])
    authorize! :view, @organization
    @activated_or_pending_kits = @organization.kits.select{|kit| kit.pending? || kit.activated? }
    @fa_user = FA::User.new
  end

  def new
    unless current_user.current_organization.new_record?
      flash[:error] = "You can only join one organization at this time."
      redirect_to organizations_url
    end

    @organization = Organization.new
  end

  def create
    @organization = Organization.new(params[:organization][:organization])

    if @organization.save
      @organization.users << current_user
      redirect_to organizations_url, :notice => "#{@organization.name} has been created"
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def connect
    @organization = Organization.find(params[:id])
    authorize! :view, @organization
    @activated_or_pending_kits = @organization.kits.select{|kit| kit.pending? || kit.activated? }
    @fa_user = FA::User.new(params[:fa_user])

    if @fa_user.authenticate
      @organization.update_attribute(:fa_member_id, @fa_user.member_id)
      flash[:notice] = "Successfully connected to Fractured Atlas!"
      redirect_to @organization
    else
      flash[:error]= "Unable to connect to your Fractured Atlas account."
      render :show
    end
  end
end
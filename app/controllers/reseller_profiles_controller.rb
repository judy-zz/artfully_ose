class ResellerProfilesController < ApplicationController

  before_filter :find_organization
  before_filter :fix_fee, :only => [ :create, :update ]

  def new
    @reseller_profile ||= ResellerProfile.new
  end

  def create
    @reseller_profile ||= ResellerProfile.new(params[:reseller_profile])
    @reseller_profile.organization = @organization

    if @reseller_profile.save
      flash[:notice] = "Your reseller profile has been created."
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @reseller_profile = @organization.reseller_profile
  end

  def update
    @reseller_profile = @organization.reseller_profile

    if @reseller_profile.update_attributes(params[:reseller_profile])
      flash[:notice] = "Your reseller profile has been updated."
      redirect_to root_path
    else
      render :edit
    end
  end

  protected

  def find_organization
    @organization = Organization.find(params[:organization_id])
    @reseller_profile = @organization.reseller_profile
    authorize! :edit, @organization
  end

  def fix_fee
    if params[:reseller_profile][:fee].present?
      params[:reseller_profile][:fee] = (params[:reseller_profile][:fee].gsub("$", "").to_f * 100).to_i
    end
  end

end

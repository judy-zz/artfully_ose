class ResellerProfilesController < ApplicationController

  before_filter :fix_fee, :only => [ :create, :update ]

  def new
    @organization = Organization.find(params[:organization_id])
    @reseller_profile = ResellerProfile.new
  end

  def create
    @organization = Organization.find(params[:organization_id])
    @reseller_profile = ResellerProfile.new(params[:reseller_profile])

    create_or_update
  end

  def edit
    @organization = Organization.find(params[:organization_id])
    @reseller_profile = @organization.reseller_profile
  end

  def update
    @organization = Organization.find(params[:organization_id])
    @reseller_profile = @organization.reseller_profile

    create_or_update
  end

  protected
  
  def create_or_update
    authorize! :edit, @organization
    @reseller_profile.organization = @organization

    if params[:reseller_profile] && @reseller_profile.update_attributes(params[:reseller_profile])
      flash[:notice] = "Your reseller profile has been updated."
    elsif @reseller_profile.save
      flash[:notice] = "Your reseller profile has been created."
    else
      flash[:error] = @reseller_profile.errors.full_messages.to_sentence
    end

    redirect_to edit_organization_reseller_profile_path(@organization, @reseller_profile)
  end

  def fix_fee
    if params[:reseller_profile][:fee].present?
      params[:reseller_profile][:fee] = (params[:reseller_profile][:fee].gsub("$", "").to_f * 100).to_i
    end
  end

end

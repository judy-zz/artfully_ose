class ResellerProfilesController < ApplicationController

  def create
    @organization = Organization.find(params[:organization_id])
    @reseller_profile = ResellerProfile.new(params[:reseller_profile])

    create_or_update
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

    if @reseller_profile.save
      flash[:notice] = "Your reseller profile has been updated."
    else
      flash[:error] = @reseller_profile.errors.full_messages.to_sentence
    end

    redirect_to @organization
  end

end

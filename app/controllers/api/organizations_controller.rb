class Api::OrganizationsController < ApiController

  def authorization
    @organization = Organization.find(params[:organization_id])
    respond_to do |format|
      format.json  { render :json => { :authorized => @organization.can?(:receive, Donation) } }
    end
  end

end

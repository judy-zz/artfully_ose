class Admin::MembershipsController < Admin::AdminController
  before_filter :authenticate_user!

  def index
  end

  def show
  end

  def new
    @organization = Organization.find(params[:organization_id])

    authorize! :create, Membership

    unless params[:user_email].blank?
      @user = User.find_by_email(params[:user_email])
      if @user.nil?
        flash[:error] = "User #{params[:user_email]} could not be found."
        redirect_to admin_organization_path(@organization)
      else
        @membership = Membership.new
        @membership.user_id = @user.athena_id
        @membership.organization_id = @organization.id

        if @membership.save
          flash[:notice] = "Your user has been added successfully."
          redirect_to admin_organization_path(@organization)
        else
          flash[:error] = "Your user has not been added."
          redirect_to admin_organization_path(@organization)
        end
      end
    end
  end

  def create
  end

  def edit
    #destroy
  end

  def update
  end

  def destroy
    @organization = Organization.find(params[:organization_id])
    @mship = Membership.find(params[:id])
    authorize! :destroy, @mship
    @mship.destroy
    redirect_to admin_organization_path(@organization), :notice => "User has been removed from #{@organization.name}" and return
  end

#  def remove_member
#    @organization = Organization.find(params[:id])
#
#    if @organization
#      @member = @organization.users.find(params[:user_id])
#      @organization.users.delete(@member)
#    end
#    redirect_to admin_organization_path(@organization), :notice => "User #{@member.email} has been removed from #{@organization.name}" and return
#  end

end
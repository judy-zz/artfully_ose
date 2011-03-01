class Admin::MembershipsController < Admin::AdminController
  before_filter :authenticate_user!

  def index
  end

  def show
  end

  def new
    @organization = Organization.find(params[:organization_id])
  end

  def create
    @organization = Organization.find(params[:organization_id])
    authorize! :create, Membership

    unless params[:user_email].blank?
      @user = User.find_by_email(params[:user_email])
      if @user.nil?
        flash[:error] = "User #{params[:user_email]} could not be found."

      elsif not (mship = Membership.find_by_user_id(@user.id)).nil?
        if mship.organization_id == @organization.id
          flash[:alert] = "#{@user.email} is already a member, and was not added a second time."
        else
          flash[:error] = "User #{params[:user_email]} is already a member of #{Organization.find(mship.organization_id).name} and cannot be a member of multiple organizations."
        end

      else
        @membership = Membership.new
        @membership.user_id = @user.id
        @membership.organization_id = @organization.id

        if @membership.save
          flash[:notice] = "#{@user.email} has been added successfully."
        #once a user can be in multiple organizations, this is a better check for duplicate memberships
        #elsif @membership.errors[:user_id] == ["has already been taken"]
        #  flash[:alert] = "#{@user.email} is already a member, and was not added a second time."
        else
          flash[:error] = "User #{@user.email} could not been added."
        end
      end
      redirect_to admin_organization_url(@organization)
    end

  end

  def edit
  end

  def update
  end

  def destroy
    @organization = Organization.find(params[:organization_id])
    @mship = Membership.find(params[:id])
    authorize! :destroy, @mship
    @mship.destroy
    redirect_to admin_organization_url(@organization), :notice => "User has been removed from #{@organization.name}" and return
  end

end
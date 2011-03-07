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

    with_user do |user|
      build_membership(user, @organization) or build_errors(user, @organization)
    end

    redirect_to admin_organization_url(@organization)
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

  private

    def build_membership(user, organization)
      membership = Membership.find_by_user_id_and_organization_id(user.id, organization.id)
      return false unless membership.nil? or !user.memberships.any?

      @membership = organization.memberships.build(:user => user)
      if @membership.save
        flash[:notice] = "#{user.email} has been added successfully."
      else
        flash[:error] = "User #{user.email} could not been added."
      end

      return true
    end

    def build_errors(user, organization)
      if user.organizations.first == organization
        flash[:alert] = "#{user.email} is already a member, and was not added a second time."
      else
        flash[:error] = "User #{params[:user_email]} is already a member of #{user.organizations.first.name} and cannot be a member of multiple organizations."
      end
    end

    def with_user(&block)
      flash[:error] = "You must specify an email" and return if params[:user_email].blank?
      user = User.find_by_email(params[:user_email])
      flash[:error] = "User #{params[:user_email]} could not be found." and return if user.nil?
      block.call(user)
    end

end
class Admin::OrganizationsController < Admin::AdminController
  def index
    @organizations = Organization.all
  end

  def show
    @organization = Organization.find(params[:id])
    @users = User.all
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def add_member

  end



end
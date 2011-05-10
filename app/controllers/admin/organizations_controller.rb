class Admin::OrganizationsController < Admin::AdminController
  def index
    @organizations = Organization.all.paginate(:page => params[:page], :per_page => 10)
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
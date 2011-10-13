class IndexController < ApplicationController
  skip_before_filter :authenticate_user!, :only => :index

  def index
    if admin_signed_in?
      redirect_to admin_root_path
    else
      render :layout => false
    end
  end

  def login_success
    redirect_to root_path
  end

  def dashboard
    if current_user.is_in_organization?
      @events = current_user.current_organization.events.paginate(:page => params[:page], :per_page => 10)
      @people = current_user.current_organization.people.limit(5)
    end
  end

end

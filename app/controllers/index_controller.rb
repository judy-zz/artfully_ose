class IndexController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [:index]

  def index
    redirect_to admin_root_path if admin_signed_in?
  end

  def login_success
    redirect_to root_path
  end

  def dashboard
    if current_user.is_in_organization?
      @events = current_user.current_organization.events.paginate(:page => params[:page], :per_page => 10)
      @recent_actions = Action.recent(current_user.current_organization, 5)
    end
  end
end

class IndexController < ApplicationController
  before_filter :authenticate_user!, :except=>:index

  def index
    render :layout => false
  end

  def login_success
    if current_user.has_role? :admin
      redirect_to admin_root_path
    else
      redirect_to dashboard_path
    end
  end
  
  def dashboard
  end

end

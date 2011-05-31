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
    if current_user.is_in_organization?
      @events = AthenaEvent.find(:all, :params => { :organizationId => "eq#{current_user.current_organization.id}" }).paginate(:page => params[:page], :per_page => 10)
      @people = AthenaPerson.find(:all, :params => { :organizationId => "eq#{current_user.current_organization.id}", :_limit => 5 })
    end
  end

end

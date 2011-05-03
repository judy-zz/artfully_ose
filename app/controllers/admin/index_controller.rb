class Admin::IndexController < Admin::AdminController
  before_filter :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to dashboard_path
  end

  def index
  end
end

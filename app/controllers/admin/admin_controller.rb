class Admin::AdminController < ActionController::Base
  protect_from_forgery
  skip_before_filter :authenticate_user!
  before_filter :authenticate_admin!
  before_filter :load_admin_stats
  layout("admin")
  
  def load_admin_stats
    @stats = AdminStats.load
  end
end

class Admin::AdminController < ActionController::Base
  protect_from_forgery
  skip_before_filter :authenticate_user!
  before_filter :authenticate_admin!
  layout("admin")
end

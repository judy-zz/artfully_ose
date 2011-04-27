class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!
  layout :specify_layout

  protected
    def specify_layout
      params[:controller].start_with?("devise") ? 'devise' : 'application'
    end

  private
    # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)
      new_user_session_path
    end

end

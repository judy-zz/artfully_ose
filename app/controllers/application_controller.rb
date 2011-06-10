class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!
  layout :specify_layout
  
  rescue_from CanCan::AccessDenied do |exception|
    if current_user.is_in_organization?
      flash[:alert] = "Sorry, we coudln't find that page!"
      redirect_to dashboard_path
    else
      flash[:notice] = "Wait, we need some more information from you first!"
      redirect_to new_organization_path
    end
  end

  protected
    def to_plural(variable, word)
      self.class.helpers.pluralize(variable, word)
    end

    def specify_layout
      params[:controller].start_with?("devise") ? 'devise' : 'application'
    end

  private
    # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)
      new_user_session_path
    end

end

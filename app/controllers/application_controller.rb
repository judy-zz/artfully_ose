class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!
  layout :specify_layout

  rescue_from CanCan::AccessDenied do |exception|
    if current_user.is_in_organization?
      flash[:alert] = "Sorry, we couldn't find that page!"
      redirect_to root_path
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
      (public_controller? or public_action?) ? 'devise' : 'application'
    end

    def authenticate_inviter!
      authorize! :adminster, :all
      super
    end

  private
    # Overwriting the sign_out redirect path method
    # def after_sign_out_path_for(resource_or_scope)
    #   new_user_session_path
    # end

    def public_controller?
      %w( devise/sessions devise/registrations devise/passwords ).include?(params[:controller])
    end

    def public_action?
      params[:controller] == "devise/invitations" and params[:action] == "edit"
    end

end

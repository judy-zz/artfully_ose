class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :metric_logged_in
  layout :specify_layout

  delegate :current_organization, :to => :current_user

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
      (public_controller? or public_action?) ? 'devise_layout' : 'application'
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
      %w( devise/sessions devise/registrations devise/passwords devise/unlocks ).include?(params[:controller])
    end

    def public_action?
      params[:controller] == "devise/invitations"
    end
  
    def metric_logged_in
      if current_user && !session[:metric_logged_in]
        session[:metric_logged_in] = RestfulMetrics::Client.add_metric(ENV["RESTFUL_METRICS_APP"], "user_logged_in", 1)
      elsif !current_user
        session[:metric_logged_in] = false
      end
    end

end

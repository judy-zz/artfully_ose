class ArtfullyOseController < ActionController::Base

  protect_from_forgery

  before_filter :authenticate_user!
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
    def public_controller?
      %w( devise/sessions devise/registrations devise/passwords devise/unlocks ).include?(params[:controller])
    end

    def public_action?
      params[:controller] == "devise/invitations"
    end
end

class Admin::AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_administration

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to dashboard_path
  end

  private
    def authorize_administration
      authorize! :adminster, :all
    end
end

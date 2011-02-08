class Admin::AdminController < ApplicationController
  before_filter :authorize_administration

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_path
  end

  private
    def authorize_administration
      authorize! :adminster, :all
    end
end

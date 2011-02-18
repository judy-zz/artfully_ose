class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :specify_layout

  protected
    def specify_layout
      params[:controller].start_with?("devise") ? 'devise' : 'application'
    end
end

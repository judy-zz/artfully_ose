class IndexController < ApplicationController

  skip_before_filter :authenticate_user!, :only => [:index]

  def index
    redirect_to admin_root_path if admin_signed_in?
  end

  def login_success
    redirect_to root_path
  end

  def dashboard
    if current_user.is_in_organization?
      @events = current_user.current_organization.events.includes(:shows, :venue).paginate(:page => params[:page], :per_page => 10)
      @recent_actions = Action.recent(current_user.current_organization, 10)
      @reseller_profile = current_user.current_organization.reseller_profile

      if @reseller_profile
        @ticket_offers = @reseller_profile.ticket_offers.offered.all
      elsif current_user.current_organization.has_kit?(:reseller)
        profile_path = new_organization_reseller_profile_path(current_user.current_organization)
        anchor = %[<a href="#{profile_path}">Setup your profile</a>]
        flash.now[:notice] = "Your reseller kit has been approved! #{anchor} so that you'll show up in the resellers directory".html_safe
      end
    end
  end

end

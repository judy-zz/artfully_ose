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
      @events = current_user.current_organization.events.paginate(:page => params[:page], :per_page => 10)
      @people = current_user.current_organization.people.limit(5)
      @reseller_profile = current_user.current_organization.reseller_profile

      if @reseller_profile
        @ticket_offers = @reseller_profile.ticket_offers.offered.all
      end
    end
  end
end

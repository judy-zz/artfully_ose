class SettlementsController < ApplicationController
  def index
    @settlements = Settlement.find_by_organization_id(current_user.current_organization.id).paginate(:page => params[:page], :per_page => 10)
  end

  def show
  end
end
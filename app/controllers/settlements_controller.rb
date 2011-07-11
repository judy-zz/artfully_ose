class SettlementsController < ApplicationController
  def index
    @settlements = Settlement.find_by_organization_id(current_user.current_organization.id)
    @settlements = @settlements.sort{|a,b| b.created_at <=> a.created_at }
    @settlements = @settlements.paginate(:page => params[:page], :per_page => 10)
  end

  def show
    @settlement = Settlement.find(params[:id])
  end
end
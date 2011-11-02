class Admin::ShowsController < Admin::AdminController
  def show
    @show = Show.find(params[:id])
  end
end
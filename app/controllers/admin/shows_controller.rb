class Admin::ShowsController < Admin::AdminController
  def show
    @performance = Show.find(params[:id])
  end
end
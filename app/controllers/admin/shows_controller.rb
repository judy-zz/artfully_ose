class Admin::ShowsController < Admin::AdminController
  def show
    @performance = AthenaPerformance.find(params[:id])
  end
end
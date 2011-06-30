class Admin::PerformancesController < Admin::AdminController
  def show
    @performance = AthenaPerformance.find(params[:id])
  end
end